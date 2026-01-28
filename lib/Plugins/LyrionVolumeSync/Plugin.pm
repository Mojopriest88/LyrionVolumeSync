package Plugins::LyrionVolumeSync::Plugin;

use strict;
use base qw(Slim::Plugin::Base);

use Slim::Utils::Log;
use Slim::Utils::Prefs;
use Slim::Player::Client;

my $prefs = Slim::Utils::Prefs::preferences('plugin.lyrionvolumesync');
my $log   = Slim::Utils::Log->addLogCategory({
	'category'     => 'plugin.lyrionvolumesync',
	'defaultLevel' => 'INFO',
	'description'  => 'PLUGIN_LYRIONVOLUMESYNC',
});

# Track volume changes to prevent infinite loops
my %lastVolume;
my $processing = 0;

sub initPlugin {
	my $class = shift;

	$class->SUPER::initPlugin(@_);

	# Subscribe to mixer (volume) events
	Slim::Control::Request::subscribe(\&volumeCallback, [['mixer']]);

	# Register Settings
	require Plugins::LyrionVolumeSync::Settings;
	Plugins::LyrionVolumeSync::Settings->new;

	$log->info("LyrionVolumeSync initialized");
}

sub shutdownPlugin {
	my $class = shift;
	Slim::Control::Request::unsubscribe(\&volumeCallback);
	$class->SUPER::shutdownPlugin(@_);
}

sub volumeCallback {
	my $request = shift;
	
	# Prevent re-entry during our own volume changes
	return if $processing;
	
	my $client = $request->client;
	return unless $client;
	
	# Ignore if this is our own update
	if ($request->source && $request->source eq 'PLUGIN_LYRIONVOLUMESYNC') {
		return;
	}

	my $changedId = $client->id;
	my $newVol = $client->volume();
	
	# Check if volume actually changed
	my $lastVol = $lastVolume{$changedId} // -1;
	return if int($newVol) == int($lastVol);
	
	$lastVolume{$changedId} = $newVol;
	$log->debug("Volume change detected on $changedId: $newVol");

	# Find all players that have this player as their source
	$processing = 1;
	
	for my $targetClient (Slim::Player::Client::clients()) {
		my $targetId = $targetClient->id;
		next if $targetId eq $changedId;
		
		my $sourceId = $prefs->get("source_$targetId");
		my $enabled = $prefs->get("enabled_$targetId");
		my $bidirectional = $prefs->get("bidirectional_$targetId");
		
		# Case 1: changed player is the source for this target
		if ($enabled && $sourceId && $sourceId eq $changedId) {
			syncVolume($targetClient, $newVol, $changedId);
		}
		
		# Case 2: bidirectional - changed player has this as source
		if ($bidirectional) {
			my $changedSource = $prefs->get("source_$changedId");
			my $changedEnabled = $prefs->get("enabled_$changedId");
			if ($changedEnabled && $changedSource && $changedSource eq $targetId) {
				syncVolume($targetClient, $newVol, $changedId);
			}
		}
	}
	
	$processing = 0;
}

sub syncVolume {
	my ($targetClient, $volume, $sourceId) = @_;
	
	my $targetId = $targetClient->id;
	my $currentVol = $targetClient->volume();
	
	# Only sync if different
	return if int($volume) == int($currentVol);
	
	$log->info("Syncing volume $volume from $sourceId to $targetId");
	$lastVolume{$targetId} = $volume;
	
	Slim::Control::Request::executeRequest(
		$targetClient, 
		['mixer', 'volume', $volume], 
		{ source => 'PLUGIN_LYRIONVOLUMESYNC' }
	);
}

1;
