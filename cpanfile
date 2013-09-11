requires "Moo" => "1.000008";
requires "MooX::Types::MooseLike::Base" => "0";
requires "Sub::Install" => "0";
requires "Test::More" => "0.96";
requires "perl" => "5.008001";
requires "strictures" => "0";
recommends "bareword::filehandles" => "0";
recommends "indirect" => "0";
recommends "multidimensional" => "0";

on 'test' => sub {
  requires "Capture::Tiny" => "0";
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec::Functions" => "0";
  requires "File::Temp" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "List::Util" => "0";
  requires "Test::More" => "0";
  requires "lib" => "0";
  requires "strict" => "0";
  requires "warnings" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::CPAN::Meta" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
};
