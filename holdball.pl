#!/usr/bin/env perl

# this program uses libsdl-perl (SDL 1.2)
# using apt to install: sudo apt install -y libsdl-perl

use strict;
use warnings;
use SDL;
use SDL::Event;
use SDLx::App;

my $TRUE = 1;
my $FALSE = 0;

# window props
my $WINDOW_WIDTH = 800;
my $WINDOW_HEIGHT = 600;

# player
my ($player_width, $player_height) = (120, 30);
my ($player_x, $player_y) = (
	($WINDOW_WIDTH - $player_width) / 2,
	$WINDOW_HEIGHT - $player_height * 4
);
my $player_speed = 10;

# ball
my ($ball_width, $ball_height) = (28, 28);
my ($ball_x, $ball_y) = (
	($WINDOW_WIDTH - $ball_width) / 2,
	($WINDOW_HEIGHT - $ball_height) / 2,
);
my ($ball_speed_x, $ball_speed_y) = (2, 2);

my ($is_left, $is_right) = ($FALSE, $FALSE);

my $app = SDLx::App->new(
	title => 'hello',
	width => $WINDOW_WIDTH ,
	height => $WINDOW_HEIGHT,
	depth => 32,
	eoq => 1,
);

# key event
$app->add_event_handler(sub {
	my ($event, $app) = @_;
	
	if ($event->type == SDL_KEYDOWN) {
		my $key = $event->key_sym;
		
		$app->stop() if $key == SDLK_q;
		
		$is_left = $TRUE if $key == SDLK_LEFT;
		$is_right = $TRUE if $key == SDLK_RIGHT;
	}
	elsif ($event->type == SDL_KEYUP) {
		my $key = $event->key_sym;
	
		$is_left = $FALSE if $key == SDLK_LEFT;
		$is_right = $FALSE if $key == SDLK_RIGHT;
	}
});

# game loop
$app->add_show_handler(sub {
	my ($delta, $app) = @_;
	
	# clear the screen
	$app->draw_rect([0, 0, $app->w, $app->h], 0x202020FF);
	
	# for the player
	if ($is_left) {
		$player_x -= $player_speed;
	}
	elsif ($is_right) {
		$player_x += $player_speed;
	}
	if ($player_x <= 0) {
		$player_x = 0;
	}
	elsif ($player_x >= $WINDOW_WIDTH - $player_width) {
		$player_x = $WINDOW_WIDTH - $player_width;
	}
	$app->draw_rect([$player_x, $player_y, $player_width, $player_height], 0xFF0000FF);
	
	# the ball!!
	$ball_x += $ball_speed_x;
	$ball_y += $ball_speed_y;
	if (intersects(
		$player_x, $player_y, $player_width, $player_height,
		$ball_x, $ball_y, $ball_width, $ball_height,
	)) {
		$ball_speed_y *= -1;
		
		$ball_speed_x *= 1.2;
		$ball_speed_y *= 1.2;
	}
	if ($ball_x < 0 || $ball_x >= $WINDOW_WIDTH - $ball_width) {
		$ball_speed_x *= -1;
	}
	if ($ball_y < 0 || $ball_y >= $WINDOW_HEIGHT - $ball_height) {
		$ball_speed_y *= -1;
	}
	$app->draw_rect([$ball_x, $ball_y, $ball_width, $ball_height], 0x00FF00FF);
	
	# update the app
	$app->update();
});

$app->run();

sub intersects {
	my ($x1, $y1, $w1, $h1, $x2, $y2, $w2, $h2) = @_;
	return
		($x1 < $x2 + $w2) && ($x2 < $x1 + $w1) &&
		($y1 < $y2 + $h2) && ($y2 < $y1 + $h1);
}

