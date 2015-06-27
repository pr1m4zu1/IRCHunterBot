use Net::IRC;
use Time::HiRes qw(usleep nanosleep);

$ducksource = 'DUCK_SOURCE';
$server = 'IRC_SERVER';
$channel = 'IRC_CHANNEL';
$botnick = 'BOT_NICKNAME';
$botnick2 = 'BOT_BACKUP_NICKNAME';
$password = 'BOT_PASSWORD';
$botadmin = 'BOT_ADMIN_NICKNAME';

$irc = new Net::IRC;

$conn = $irc->newconn(Nick => $botnick, Server => $server, Port => IRC_SERVER_PORT, Username => $botnick);

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
	$self->join($channel);
	$self->privmsg('nickserv', "/nick $botnick");
}

sub on_msg {
	$self = shift;
	$event = shift;
	if ($event->nick eq $botadmin) {
		foreach $arg ($event->args) {
			if ($arg =~ m/uptime/) {
				$self->privmsg($botadmin, `uptime`);
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
				usleep(250000);
				$self->privmsg($channel, ".bang");
			}
			if (($arg =~ m/missed/) || ($arg =~ m/jammed/) || ($arg =~ m/luck/) || ($arg =~ m/WTF/)) {
				$self->privmsg('nickserv', "/nick $botnick2");
				$self->privmsg($channel, ".bang");
				$self->privmsg('nickserv', "/nick $botnick");
			}
			if (($arg =~ m/script/) || ($arg =~ m/period/)) {
				$self->privmsg('nickserv', "/nick $botnick2");
				$self->privmsg($channel, ".bang");
			}
		}
	}
}