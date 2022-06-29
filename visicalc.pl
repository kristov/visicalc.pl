#!/usr/bin/env perl

use strict;
use warnings;

my @VALUES;
my @OPS;

while (1) {
    print "> ";
    my $input = <STDIN>;
    evaluate($input);
}

sub evaluate {
    my ($input) = @_;
    if ($input =~ /^[rc]/i) {
        @VALUES = ();
        @OPS = ();
        return;
    }
    my @tokens = split(/\s+/, $input);
    for my $token (@tokens) {
        if ($token =~ /^0x/) {
            push @VALUES, oct($token);
            next;
        }
        if ($token =~ /^0b/) {
            push @VALUES, oct($token);
            next;
        }
        if ($token =~ /^\$([a-fA-F0-9]+)/) {
            push @VALUES, oct("0x" . $1);
            next;
        }
        if ($token =~ /^b([01]+)/) {
            push @VALUES, oct("0b" . $1);
            next;
        }
        if ($token =~ /^([01]+)b/) {
            push @VALUES, oct("0b" . $1);
            next;
        }
        if ($token =~ /^\%([01]+)/) {
            push @VALUES, oct("0b" . $1);
            next;
        }
        if ($token =~ /^[0-9]+$/) {
            push @VALUES, $token;
            next;
        }
        if ($token =~ /^[\-\+\/\*]$/) {
            push @OPS, $token;
            next;
        }
    }
    printf("values:\n");
    for my $value (@VALUES) {
        printf("  ");
        print_value($value);
    }
    if (!@OPS) {
        return;
    }
    printf("\noperations:\n");
    while (my $op = shift @OPS) {
        my $l = shift @VALUES;
        my $r = shift @VALUES;
        if (!defined $l || !defined $r) {
            printf("ERR: not enough values for op '%s'\n", $op);
            return;
        }
        my $evaluate = "$l $op $r";
        printf("  [ %s ] == ", $evaluate);
        my $result = eval $evaluate;
        print_value($result);
        unshift @VALUES, $result;
    }
}

sub print_value {
    my ($value) = @_;
    printf("hex: 0x%x  bin: 0b%b  dec: %d\n", $value, $value, $value);
}
