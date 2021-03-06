use inc::Module::Install;

RTx 'RT-Extension-Assets';
all_from 'lib/RT/Extension/Assets.pm';
readme_from 'lib/RT/Extension/Assets.pm';
license  'gplv2';
perl_version 5.010001;

no_index package => "HTML::Mason::Commands";
no_index package => "RT::Transaction";
no_index package => "RT::CustomField";
no_index package => "RT::CustomFields";

requires_rt("4.2.1");
test_requires "Test::Warn";

my ($loaded) = ($INC{'RT.pm'} =~ /^(.*)[\\\/]/);
my $lib_path = join( ' ', "$RT::LocalPath/lib", $loaded );

substitute(
    {
        RT_LIB_PATH  => $lib_path,
    },
    {
        sufix => '.in'
    },
    q(xt/lib/RT/Extension/Assets/Test.pm),
);

sign;
WriteAll;
