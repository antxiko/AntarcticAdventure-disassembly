# The game

A penguin crosses Antarctica from base to base. He always runs forwards, you
steer him across the track and jump whatever gets in the way, and each leg has
a distance to cover and a clock running out. Everything here comes from reading
the code that does it.

## The route: ten stops

The table at 0x4AD9 holds ten four-byte entries, each carrying the leg's
distance, the map square where it starts and the time you're given. The table
ends exactly where code starts again, which is what fixes its size without
anyone having to guess.

| Stage | Distance | Time | Base you reach |
|---|---|---|---|
| 1 | 1500 m | 100 s | USA |
| 2 | 1700 m | 120 s | THE SOUTH POLE |
| 3 | 1100 m | 80 s | USA |
| 4 | 1200 m | 80 s | USA |
| 5 | 1200 m | 80 s | ARGENTINA |
| 6 | 500 m | 40 s | UNITED KINGDOM |
| 7 | 2600 m | 165 s | JAPAN |
| 8 | 1200 m | 90 s | AUSTRALIA |
| 9 | 1500 m | 100 s | AUSTRALIA |
| 10 | 1200 m | 90 s | FRANCE |

Careful pairing those two columns up, because they run off different counters
one step apart. Distance and time come from the index in 0xE0E8, which during
stage *k* holds *k−1*; the base name comes from the one in 0xE0E1, and the
arrival scene bumps it **before** writing it out, so it points at where you're
getting to, not where you came from. That's why FRANCE, index 0, is both the
base you set off from and the one at the end: the lap closes on stage 10.

The sixth is the game's sprint, half a kilometre, and the seventh its marathon:
2600 metres with nearly three minutes to do it in. Past the tenth the counter
wraps around, so the route goes all the way round.

Each stop has its flag, decompressed into the sprite patterns just before you
arrive. Seven pictures cover ten stops —the American one turns up three times
and the Australian twice— and each lands on its own country, including the
penguin that stands in as a flag at the South Pole.

## Leftover time isn't a gift

Reaching a base turns whatever's left on the clock into points, a hundred per
second, ticking as it goes down. But it's also written down: each stage's
surplus is filed in its own slot and **next time round it gets deducted from
that same stage's allowance**, once it goes past ten. The better you do, the
less room you're given on the next lap.

## The throttle isn't upside down: what's in there is a period

The controls are four directions and a button. Left and right move the penguin
across the track, between columns 20 and 204, and the button jumps. Up and down
work the speed, and they do what you'd expect: **up accelerates and down
brakes**.

What throws you is what the game keeps in 0xE100, which isn't the speed but its
**period**: how many frames go by between two advances. The higher it is, the
longer the wait and the slower he goes. That's why accelerating subtracts from
it and braking adds to it, and why the speedometer has to invert it with a
`cpl` before drawing the bar. The period lives between 8 —flat out— and 19, and
every stage starts at 16.

What is lopsided is what each one costs: gaining a step takes twelve frames and
losing one only four, so **he brakes three times faster than he accelerates**.

## What's out on the track

There are seven kinds of obstacle, and the table defining them gives each one a
pointer to its artwork and two collision windows: a position and a width,
twice. The collision is only checked on step 13 of the fifteen the approach
lasts, which is when the obstacle is level with the penguin.

Three of the seven are holes in the ice. Catch one by the edge and you trip and
roll; catch it square and you fall in and stay there flailing until you press
the button, while the clock keeps running, which is the real punishment. And
out of those same holes come two things: the seal, which is the hole's own
animation, and the fish, released when the hole reaches step seven. The fish
comes up on its own arc, and landing on it is worth 300 points.

The fish is **a single sprite** —attribute 15— with eight drawings, four facing
each way. The drawing alternates every sixteen frames on the way up, and when
it starts to fall it switches to the big one, which is the cheap way of making
it look like it's coming at you.

Jumping clean over an obstacle scores too, though barely: thirty points. And
two of the kinds, the last two, are collected rather than dodged: touching them
makes a noise, wipes them off the ice and pays 500.

## The panel

The top two rows of the screen aren't a picture: they're written by a single
string that drops five labels in five different places, with the numbers going
on top.

    1P  <score>       HI  <high score>     STAGE  <stage>
    TIME  <clock>          <distance left>

It's all packed decimal, two digits to a byte, which is what lets it be added
with a single instruction and written out without dividing by ten. The score is
three bytes and pegs at 999999 if you get that far; the high score is another
three, and they're the only ones that survive a reset, because the wipe starts
three bytes further along.

## The demo

Leave the game alone and it starts a game that plays itself for 1852 steps.
There's no intelligence behind it: the controls come out of a 64-byte recording
carried in the cartridge itself, and the reader takes one every 32 frames.

While it runs, the bit that says "a real game is in progress" is off, and that
has a nice consequence: the scoring routine leaves by the back door on its
second instruction. The demo plays, crashes and jumps, but never scores.

## Starting a game

You press **1** to play with a joystick or **2** to play with the keyboard.
That key is checked every single frame, on any screen, and the routine handling
it does something unusual: it eats its own return address so it never goes back
to whoever called it, and plants the menu right there.

From the keyboard it uses the arrow row and the space bar, and the code drops
them into the same bits the joystick's own come in on, so from that point the
game has no idea which of the two you're using.
