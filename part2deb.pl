#!/bin/perl

#
# Copyright (c) 2016 Adrian Schroeter, SUSE Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program (see the file COPYING); if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
#
################################################################

use strict;
use YAML::XS;

my $source_dir = shift @ARGV;
my $buildroot = shift @ARGV;
my $subdir = shift @ARGV;
my $outdir = shift @ARGV;

my ($yaml) = YAML::XS::LoadFile("$source_dir/snapcraft.yaml");
return {'error' => "Failed to parse yaml file"} unless $yaml;

for my $key (sort keys(%{$yaml->{'parts'} || {}})) {
  # write the part.yaml
  my $part = $yaml->{'parts'}->{$key};
  my $package_name = "build-snapcraft-part-${key}";
  my $package_dir_name = "${package_name}_$yaml->{version}";

  my $part_dir = "$subdir/$key";
  my $part_file = "$buildroot/$package_dir_name/$part_dir/part.yaml";

  # copy content
  mkdir $buildroot;
  mkdir "$buildroot/$package_dir_name";
  mkdir "$buildroot/$package_dir_name/$subdir";
  system("cp -a '$source_dir' '$buildroot/$package_dir_name/$part_dir'");

  $part->{source} = "$part_dir/$part->{source}" if defined($part->{source});
  $part->{maintainer} ||= "generated\@build.script";
  $part->{description} ||= $yaml->{'description'};

  # create part.yaml
  open F, '>', $part_file;
  print F YAML::XS::Dump({$key => $part});
  close F;

  # Calculate deps
  my @packdeps;
  for my $p (@{$part->{'stage-packages'} || []}) {
    push @packdeps, $p;
  }
  for my $p (@{$part->{'build-packages'} || []}) {
    push @packdeps, $p;
  }


  # create package
  # create control file
  mkdir "$buildroot/$package_dir_name/DEBIAN";
  open(my $fh, '>', "$buildroot/$package_dir_name/DEBIAN/control");
  print $fh "Package: $package_name\n";
  print $fh "Architecture: all\n";
  print $fh "Maintainer: $part->{maintainer}\n";
  print $fh "Depends: debconf (>= 0.5.00), ".join(", ", @packdeps)."\n";
  print $fh "Priority: optional\n";
  print $fh "Version: 0.5\n";
  print $fh "Description: empty\n";
  close $fh;

  open(my $fh, '>', "$buildroot/$package_dir_name/DEBIAN/dirs");
  print $fh "$subdir\n";
  close $fh;

  # archive it
  chdir($buildroot);
  system("dpkg-deb --build $package_dir_name");
  # copy for export
  system("cp *.deb $outdir");
}

