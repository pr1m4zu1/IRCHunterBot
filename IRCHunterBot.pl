use Net::IRC;
use Time::HiRes qw(usleep nanosleep);

$ducksource = 'DUCK_SOURCE_NICK';
$server = 'SERVER_ADDRESS';
$port = SERVER_PORT;
$channel = 'HUNT_CHANNEL';
$botnick = 'BOT_NAME';
$botnick2 = 'BACKUP_BOT_NAME';
$currnick = $botnick;
$snick = $currnick;
$password = 'BOT_PASSWORD';
$botadmin = 'BOT_ADMIN_NICK';
$delay = DELAY_TIME_MICROSECONDS;

$irc = new Net::IRC;

$conn = $irc->newconn(Nick => $botnick, Server => $server, Port => $port, Username => $botnick, Ircname => $botnick);

$conn->add_global_handler('376', \&on_connect);
$conn->add_global_handler('disconnect', \&on_disconnect);
$conn->add_global_handler('kick', \&on_kick);
$conn->add_global_handler('msg', \&on_msg);
$conn->add_global_handler('public', \&on_public);

$irc->start;

sub on_connect {
	$self = shift;
	$self->privmsg('nickserv', "identify $password");
	$self->join($channel);
	print "Connected\n";
}

sub on_disconnect {
	$self = shift;
	print "Disconnected, attempting to reconnect\n";
	$self->connect();
}

sub on_kick {
	$self = shift;
	print "Kicked, rejoining\n";
	$self->join($channel);
	$self->nick($currnick);
}

sub on_msg {
	$self = shift;
	$event = shift;
	if ($event->nick eq $botadmin) {
		foreach $arg ($event->args) {
			if ($arg =~ m/uptime/) {
				$self->privmsg($botadmin, `uptime`);
			}
			if ($arg =~ m/changenick/) {
				change_nick();
				$self->privmsg($botadmin, "Nick changed to $currnick");
			}
		}
	}
}

sub on_public {
	$self = shift;
	$event = shift;
	if ($event->nick eq $ducksource) {
		foreach $arg ($event->args) {
			if (($arg =~ m/</) && ($arg !~ m/>/)) {
				print Time::HiRes::time;
				print "\n";
				usleep($delay);
				print Time::HiRes::time;
				print "\n";
				$self->privmsg($channel, ".bang");
			}
			if (($arg =~ m/HunterBot/) && ($arg =~ m/in\ 7\ seconds/)) {
				change_nick();
				$self->privmsg($channel, ".bang");
				change_nick();
			}
			if (($arg =~ m/HunterBot/) && ($arg =~ m/cool\ down/)) {
				change_nick();
				$self->privmsg($channel, ".bang");
			}
			if (($arg =~ m/HunterBot/) && ($arg =~ m/you\ shot/)) {
				@words = split(/ /, $arg);
				$time = $words[6];
				print "\$time = $time\n";
				if ($time < 1.100) {
					print "\$time is less than 1.100\n";
					print "\$delay = $delay\n";
					$delay = ($delay + 100000);
					print "\$delay = $delay\n";
				}
				if ($time > 1.400) {
					print "\$time is greater than 1.400\n";
					print "\$delay = $delay\n";
					$delay = ($delay - 100000);
					print "\$delay = $delay\n";
				}
			}
		}
	}
}

sub change_nick {
	$snick = $currnick;
	if ($snick eq $botnick) {
		$self->nick($botnick2);
		$currnick = $botnick2;
	} 
	if ($snick eq $botnick2) {
		$self->nick($botnick);
		$currnick = $botnick;
	}
	$snick = $currnick;
	print "Nick changed to $currnick\n";
}