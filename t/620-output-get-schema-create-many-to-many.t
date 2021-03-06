#   $Id: 620-output-get-schema-create-many-to-many.t,v 1.4 2009/11/12 09:56:50 aff Exp $

use warnings;
use strict;

use Data::Dumper;
use Test::More;
use Test::Exception;
use File::Spec::Functions;
use lib catdir qw ( blib lib );

plan tests => 14;

use lib q{lib};
use_ok ('Parse::Dia::SQL');
use_ok ('Parse::Dia::SQL::Output');
use_ok ('Parse::Dia::SQL::Output::DB2');

# 1. parse input
my $diasql =  Parse::Dia::SQL->new( file => catfile(qw(t data many_to_many.dia)), db => 'db2' );
isa_ok($diasql, q{Parse::Dia::SQL}, q{Expect a Parse::Dia::SQL object});
is($diasql->convert(), 1, q{Expect convert to return 1});

my $classes       = $diasql->get_classes_ref();
my $associations  = $diasql->get_associations_ref();
my $smallpackages = $diasql->get_smallpackages_ref();

# check parsed content
ok(defined($classes) && ref($classes) eq q{ARRAY} && scalar(@$classes), q{Non-empty array ref});
ok(defined($associations) && ref($associations) eq q{ARRAY} && scalar(@$associations), q{Non-empty array ref});

# 2. get output instance
my $subclass   = undef;
lives_ok(sub { $subclass = $diasql->get_output_instance(); },
  q{get_output_instance (db2) should not die});

isa_ok($subclass, 'Parse::Dia::SQL::Output')
  or diag(Dumper($subclass));
isa_ok($subclass, 'Parse::Dia::SQL::Output::DB2')
  or diag(Dumper($subclass));
can_ok($subclass, 'get_schema_create');

# 3. schema
my $schema = $subclass->get_schema_create();

like($schema, qr|.*
  create \s+ table \s+ student \s*
.*|six, q{Check syntax for sql create table student});
like($schema, qr|.*
  create \s+ table \s+ course \s*
.*|six, q{Check syntax for sql create table course});
like($schema, qr|.*
  create \s+ table \s+ student_course \s*
.*|six, q{Check syntax for sql create table student_course});

# Note: Associations are tested in 650-output-get-create-associations.t

__END__
