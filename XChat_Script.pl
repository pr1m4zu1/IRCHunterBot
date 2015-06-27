use strict;
use warnings;
use Xchat qw( :all );

register('HunterBot Script', '0.2', 'Destroy all ducks');

foreach ('Channel Message', 'Channel Msg Hilight') {
	hook_print($_, \&check_duck);
}

sub check_duck {
	return EAT_NONE if ($_[0][1] !~ m/</);
	prnt("$_[0][0]");
	my $userinfo = $_[0][0];
	prnt("$userinfo");
	if ($userinfo eq 'jmduck') {
		delaycommand("msg ##duckhunt2 .bang");
	}
	else {
		hook_timer( 0, sub {
			prnt("No shots for fakers");
			return REMOVE;
		});
	}
	return EAT_NONE;
}

sub delaycommand {
	my $command = $_[0];
	hook_timer( 250, sub { command($command); return REMOVE; } );
	return EAT_NONE;
}