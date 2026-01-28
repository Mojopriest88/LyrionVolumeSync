package Plugins::LyrionVolumeSync::Settings;

use strict;
use base qw(Slim::Web::Settings);

use Slim::Utils::Log;
use Slim::Utils::Prefs;
use Slim::Player::Client;

my $prefs = Slim::Utils::Prefs::preferences('plugin.lyrionvolumesync');
my $log   = Slim::Utils::Log->addLogCategory({
	'category'     => 'plugin.lyrionvolumesync',
	'defaultLevel' => 'INFO',
	'description'  => 'PLUGIN_LYRIONVOLUMESYNC',
});

sub name {
	return 'PLUGIN_LYRIONVOLUMESYNC';
}

sub page {
	return 'plugins/LyrionVolumeSync/settings.html';
}

sub prefs {
	return $prefs;
}

sub handler {
	my ($class, $client, $params, $callback, @args) = @_;

	# Save settings if submitted
	if ($params->{'saveSettings'}) {
		for my $c (Slim::Player::Client::clients()) {
			my $id = $c->id;
			$prefs->set("enabled_$id", $params->{"enabled_$id"} ? 1 : 0);
			$prefs->set("source_$id", $params->{"source_$id"} || '');
			$prefs->set("bidirectional_$id", $params->{"bidirectional_$id"} ? 1 : 0);
		}
		$log->info("Settings saved");
	}

	# Build player list for template
	my @allPlayers;
	for my $c (Slim::Player::Client::clients()) {
		push @allPlayers, {
			id   => $c->id,
			name => $c->name,
		};
	}

	my @players;
	for my $c (Slim::Player::Client::clients()) {
		my $id = $c->id;
		
		# Build source options (all players except self)
		my @sourceOptions;
		push @sourceOptions, { id => '', name => '-- None --', selected => 0 };
		for my $other (@allPlayers) {
			next if $other->{id} eq $id;
			my $isSelected = ($prefs->get("source_$id") // '') eq $other->{id};
			push @sourceOptions, {
				id       => $other->{id},
				name     => $other->{name},
				selected => $isSelected,
			};
		}
		
		push @players, {
			id            => $id,
			name          => $c->name,
			enabled       => $prefs->get("enabled_$id"),
			sourceOptions => \@sourceOptions,
			bidirectional => $prefs->get("bidirectional_$id"),
		};
	}

	$params->{'players'} = \@players;

	return $class->SUPER::handler($client, $params, $callback, @args);
}

1;
