use strict;
use warnings;
use lib 'lib';

use Net::DNS::SPF::Expander;
use IO::All -utf8;
use Data::Printer;

use Test::More tests => 7;
use Test::Exception;

my $backup_file  = 't/etc/test_zonefile_idem.bak';
my $new_file     = 't/etc/test_zonefile_idem.new';
my @output_files = ( $backup_file, $new_file );
for my $deletion (@output_files) {
    if ( -e $deletion ) {
        lives_ok { unlink $deletion } "I am deleting $deletion";
    } else {
        ok(1==1, "$deletion was already deleted");
    }
}

my $file_to_expand = 't/etc/test_zonefile_idem';

my $expander;
lives_ok {
    $expander = Net::DNS::SPF::Expander->new( input_file => $file_to_expand );
}
"I can make a new expander";

my $string;
lives_ok { $string = $expander->write } "I can call write on my expander";

my $expected_file_content = <<EOM;
\$ORIGIN campusexplorer.com.

yo      CNAME   111.222.333.4.
mama    CNAME   222.333.444.5.

;*               TXT     "v=spf1 include:_spf2.campusexplorer.com include:_spf3.campusexplorer.com include:_spf4.campusexplorer.com include:_spf5.campusexplorer.com include:_spf6.campusexplorer.com ~all"
;*               SPF     "v=spf1 include:_spf2.campusexplorer.com include:_spf3.campusexplorer.com include:_spf4.campusexplorer.com include:_spf5.campusexplorer.com include:_spf6.campusexplorer.com ~all"
;@               TXT     "v=spf1 include:_spf2.campusexplorer.com include:_spf3.campusexplorer.com include:_spf4.campusexplorer.com include:_spf5.campusexplorer.com include:_spf6.campusexplorer.com ~all"
;@               SPF     "v=spf1 include:_spf2.campusexplorer.com include:_spf3.campusexplorer.com include:_spf4.campusexplorer.com include:_spf5.campusexplorer.com include:_spf6.campusexplorer.com ~all"
;_spf.campusexplorer.com.    SPF     "v=spf1 include:_spf2.campusexplorer.com include:_spf3.campusexplorer.com include:_spf4.campusexplorer.com include:_spf5.campusexplorer.com include:_spf6.campusexplorer.com ~all"
;_spf.campusexplorer.com.    TXT     "v=spf1 include:_spf2.campusexplorer.com include:_spf3.campusexplorer.com include:_spf4.campusexplorer.com include:_spf5.campusexplorer.com include:_spf6.campusexplorer.com ~all"
;_spf2.campusexplorer.com.   SPF     "v=spf1 ip4:216.239.32.0/19 ip4:64.233.160.0/19 ip4:66.249.80.0/20 ip4:72.14.192.0/18 ip4:209.85.128.0/17 ip4:66.102.0.0/20 ip4:74.125.0.0/16 ip4:64.18.0.0/20 ip4:207.126.144.0/20 ip4:173.194.0.0/16 ip6:2001:4860:4000::/36 ip6:2404:6800:4000::/36"
;_spf2.campusexplorer.com.   TXT     "v=spf1 ip4:216.239.32.0/19 ip4:64.233.160.0/19 ip4:66.249.80.0/20 ip4:72.14.192.0/18 ip4:209.85.128.0/17 ip4:66.102.0.0/20 ip4:74.125.0.0/16 ip4:64.18.0.0/20 ip4:207.126.144.0/20 ip4:173.194.0.0/16 ip6:2001:4860:4000::/36 ip6:2404:6800:4000::/36"
;_spf3.campusexplorer.com.   SPF     "v=spf1 ip6:2607:f8b0:4000::/36 ip6:2800:3f0:4000::/36 ip6:2a00:1450:4000::/36 ip6:2c0f:fb50:4000::/36 include:_netblocks3.google.com ip4:208.115.214.0/24 ip4:74.63.202.0/24 ip4:75.126.200.128/27 ip4:75.126.253.0/24 ip4:67.228.50.32/27 ip4:174.36.80.208/28"
;_spf3.campusexplorer.com.   TXT     "v=spf1 ip6:2607:f8b0:4000::/36 ip6:2800:3f0:4000::/36 ip6:2a00:1450:4000::/36 ip6:2c0f:fb50:4000::/36 include:_netblocks3.google.com ip4:208.115.214.0/24 ip4:74.63.202.0/24 ip4:75.126.200.128/27 ip4:75.126.253.0/24 ip4:67.228.50.32/27 ip4:174.36.80.208/28"
;_spf4.campusexplorer.com.   SPF     "v=spf1 ip4:174.36.92.96/27 ip4:69.162.98.0/24 ip4:74.63.194.0/24 ip4:74.63.234.0/24 ip4:74.63.235.0/24 ip4:208.115.235.0/24 ip4:74.63.231.0/24 ip4:74.63.247.0/24 ip4:74.63.236.0/24 ip4:208.115.239.0/24 ip4:173.193.132.0/24 ip4:173.193.133.0/24"
;_spf4.campusexplorer.com.   TXT     "v=spf1 ip4:174.36.92.96/27 ip4:69.162.98.0/24 ip4:74.63.194.0/24 ip4:74.63.234.0/24 ip4:74.63.235.0/24 ip4:208.115.235.0/24 ip4:74.63.231.0/24 ip4:74.63.247.0/24 ip4:74.63.236.0/24 ip4:208.115.239.0/24 ip4:173.193.132.0/24 ip4:173.193.133.0/24"
;_spf5.campusexplorer.com.   SPF     "v=spf1 ip4:208.117.48.0/20 ip4:50.31.32.0/19 ip4:198.37.144.0/20 ip4:198.21.0.0/21 ip4:96.43.144.0/20 ip4:182.50.76.0/22 ip4:202.129.242.0/23 ip4:204.14.232.0/21 ip4:62.17.146.128/26 ip4:64.18.0.0/20 ip4:207.126.144.0/20 ip4:64.18.7.11 ip4:64.18.7.13"
;_spf5.campusexplorer.com.   TXT     "v=spf1 ip4:208.117.48.0/20 ip4:50.31.32.0/19 ip4:198.37.144.0/20 ip4:198.21.0.0/21 ip4:96.43.144.0/20 ip4:182.50.76.0/22 ip4:202.129.242.0/23 ip4:204.14.232.0/21 ip4:62.17.146.128/26 ip4:64.18.0.0/20 ip4:207.126.144.0/20 ip4:64.18.7.11 ip4:64.18.7.13"
;_spf6.campusexplorer.com.   SPF     "v=spf1 ip4:64.18.7.14 ip4:64.18.7.10 ip4:4.34.83.138 ip4:76.79.193.70 ip4:23.21.139.17 ip4:204.14.234.64/28 ip4:182.50.78.64/28 ip4:96.43.148.64/31"
;_spf6.campusexplorer.com.   TXT     "v=spf1 ip4:64.18.7.14 ip4:64.18.7.10 ip4:4.34.83.138 ip4:76.79.193.70 ip4:23.21.139.17 ip4:204.14.234.64/28 ip4:182.50.78.64/28 ip4:96.43.148.64/31"
_spf.campusexplorer.com.	600	IN	TXT	"v=spf1 _spf1.campusexplorer.com _spf2.campusexplorer.com _spf3.campusexplorer.com _spf4.campusexplorer.com _spf5.campusexplorer.com ~all"
*	600	IN	TXT	"v=spf1 _spf1.campusexplorer.com _spf2.campusexplorer.com _spf3.campusexplorer.com _spf4.campusexplorer.com _spf5.campusexplorer.com ~all"
@	600	IN	TXT	"v=spf1 _spf1.campusexplorer.com _spf2.campusexplorer.com _spf3.campusexplorer.com _spf4.campusexplorer.com _spf5.campusexplorer.com ~all"
_spf.campusexplorer.com.	600	IN	SPF	"v=spf1 _spf1.campusexplorer.com _spf2.campusexplorer.com _spf3.campusexplorer.com _spf4.campusexplorer.com _spf5.campusexplorer.com ~all"
*	600	IN	SPF	"v=spf1 _spf1.campusexplorer.com _spf2.campusexplorer.com _spf3.campusexplorer.com _spf4.campusexplorer.com _spf5.campusexplorer.com ~all"
@	600	IN	SPF	"v=spf1 _spf1.campusexplorer.com _spf2.campusexplorer.com _spf3.campusexplorer.com _spf4.campusexplorer.com _spf5.campusexplorer.com ~all"
_spf1.campusexplorer.com.	600	IN	TXT	"v=spf1 ip4:64.18.7.14 ip4:64.18.7.10 ip4:4.34.83.138 ip4:76.79.193.70 ip4:23.21.139.17 ip4:204.14.234.64/28 ip4:182.50.78.64/28 ip4:96.43.148.64/31 ip4:174.36.92.96/27 ip4:69.162.98.0/24 ip4:74.63.194.0/24 ip4:74.63.234.0/24 ip4:74.63.235.0/24"
_spf2.campusexplorer.com.	600	IN	TXT	"v=spf1 ip4:208.115.235.0/24 ip4:74.63.231.0/24 ip4:74.63.247.0/24 ip4:74.63.236.0/24 ip4:208.115.239.0/24 ip4:173.193.132.0/24 ip4:173.193.133.0/24 ip4:216.239.32.0/19 ip4:64.233.160.0/19 ip4:66.249.80.0/20 ip4:72.14.192.0/18 ip4:209.85.128.0/17"
_spf3.campusexplorer.com.	600	IN	TXT	"v=spf1 ip4:66.102.0.0/20 ip4:74.125.0.0/16 ip4:64.18.0.0/20 ip4:207.126.144.0/20 ip4:173.194.0.0/16 ip6:2001:4860:4000::/36 ip6:2404:6800:4000::/36 ip4:208.117.48.0/20 ip4:50.31.32.0/19 ip4:198.37.144.0/20 ip4:198.21.0.0/21 ip4:96.43.144.0/20"
_spf4.campusexplorer.com.	600	IN	TXT	"v=spf1 ip4:182.50.76.0/22 ip4:202.129.242.0/23 ip4:204.14.232.0/21 ip4:62.17.146.128/26 ip4:64.18.7.11 ip4:64.18.7.13 ip6:2607:f8b0:4000::/36 ip6:2800:3f0:4000::/36 ip6:2a00:1450:4000::/36 ip6:2c0f:fb50:4000::/36 ip4:208.115.214.0/24 ip4:74.63.202.0/24"
_spf5.campusexplorer.com.	600	IN	TXT	"v=spf1 ip4:75.126.200.128/27 ip4:75.126.253.0/24 ip4:67.228.50.32/27 ip4:174.36.80.208/28"
_spf1.campusexplorer.com.	600	IN	SPF	"v=spf1 ip4:64.18.7.14 ip4:64.18.7.10 ip4:4.34.83.138 ip4:76.79.193.70 ip4:23.21.139.17 ip4:204.14.234.64/28 ip4:182.50.78.64/28 ip4:96.43.148.64/31 ip4:174.36.92.96/27 ip4:69.162.98.0/24 ip4:74.63.194.0/24 ip4:74.63.234.0/24 ip4:74.63.235.0/24"
_spf2.campusexplorer.com.	600	IN	SPF	"v=spf1 ip4:208.115.235.0/24 ip4:74.63.231.0/24 ip4:74.63.247.0/24 ip4:74.63.236.0/24 ip4:208.115.239.0/24 ip4:173.193.132.0/24 ip4:173.193.133.0/24 ip4:216.239.32.0/19 ip4:64.233.160.0/19 ip4:66.249.80.0/20 ip4:72.14.192.0/18 ip4:209.85.128.0/17"
_spf3.campusexplorer.com.	600	IN	SPF	"v=spf1 ip4:66.102.0.0/20 ip4:74.125.0.0/16 ip4:64.18.0.0/20 ip4:207.126.144.0/20 ip4:173.194.0.0/16 ip6:2001:4860:4000::/36 ip6:2404:6800:4000::/36 ip4:208.117.48.0/20 ip4:50.31.32.0/19 ip4:198.37.144.0/20 ip4:198.21.0.0/21 ip4:96.43.144.0/20"
_spf4.campusexplorer.com.	600	IN	SPF	"v=spf1 ip4:182.50.76.0/22 ip4:202.129.242.0/23 ip4:204.14.232.0/21 ip4:62.17.146.128/26 ip4:64.18.7.11 ip4:64.18.7.13 ip6:2607:f8b0:4000::/36 ip6:2800:3f0:4000::/36 ip6:2a00:1450:4000::/36 ip6:2c0f:fb50:4000::/36 ip4:208.115.214.0/24 ip4:74.63.202.0/24"
_spf5.campusexplorer.com.	600	IN	SPF	"v=spf1 ip4:75.126.200.128/27 ip4:75.126.253.0/24 ip4:67.228.50.32/27 ip4:174.36.80.208/28"

greasy  CNAME   333.444.555.6.
granny  CNAME   666.777.888.9.
EOM

ok( -e $_, "File $_ was created" ) for @output_files;

ok( $string eq $expected_file_content, "My new file contains what I expected" );
