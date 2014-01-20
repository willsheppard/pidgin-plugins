use Purple;
use Data::Dumper;
%PLUGIN_INFO = (
    perl_api_version => 2,
    name => "Zenity notifications",
    version => "0.2",
    summary => "Use zenity notification for messages.",
    description => "Use zenity notification for messages. Thanks to daniel\@netwalk.org for growl.pl, from which this script is copy & pasted",
    author => "will.sheppard\@net-a-porter.com",
    url => "http://pidgin.im",
    load => "plugin_load",
    # prefs_info => "prefs_info_cb",
    unload => "plugin_unload"
);
sub prefs_info_cb {
    # Get all accounts to show in the drop-down menu
    @accounts = Purple::Accounts::get_all();

    $frame = Purple::PluginPref::Frame->new();

    # $acpref = Purple::PluginPref->new_with_name_and_label(
    #     "/plugins/core/url_shorten/max_url_length", "Max length for url: ");
    $acpref->set_bounds(10,100);

    $frame->add($acpref);

    return $frame;
}
sub plugin_init {
    return %PLUGIN_INFO;
}
sub receiving_im_msg_cb {
    my ($account, $who, $msg, $conv, $flags) = @_;
    my $accountname = $account->get_username();
    Purple::Debug::info("zenity", '================================================');
    Purple::Debug::info("zenity", Dumper $account->get_protocol_id() );
    $msg =~ s/<[^>]+>//g;
    $msg =~ s/"/''/g;
    next if $msg =~ /\?OTR/;
    Purple::Debug::info("zenity", Dumper($msg));
    my $buddy = Purple::Find::buddy($account, $who);
    # NOTE: $buddy is undef on Pidgin 2.10.3, Ubuntu 12.04
    Purple::Debug::info("zenity", "buddy = ".Dumper($buddy));
#    $display_name = $buddy->get_alias() ||  $buddy->get_name();
#    $display_name =~ s/"/''/g;
    # play a sound
    system("/usr/bin/play /usr/share/sounds/gnome/default/alerts/drip.ogg");
    # display a popup message
    my $title = "You have received a message in Pidgin";
    system("/usr/bin/zenity --info --title \"$title\" --text \"$msg\" --width 400");
    $_[2];
}

sub plugin_load {
    my $plugin = shift;
    Purple::Debug::info("growl", "Growl $PLUGIN_INFO{version} Loaded.\n");
    # A pointer to the handle to which the signal belongs
    my $convs_handle = Purple::Conversations::get_handle();

    # Connect the perl sub 'receiving_im_msg_cb' to the event
    # 'receiving-im-msg'
    Purple::Signal::connect($convs_handle, "receiving-im-msg",
        $plugin,
        \&receiving_im_msg_cb, 0);
}
sub plugin_unload {
    my $plugin = shift;
    Purple::Debug::info("growl", "Growl $PLUGIN_INFO{version} Unloaded.\n");
}
