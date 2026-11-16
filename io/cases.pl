:- module(cases, [title/1, case/3]).
:- use_module('../prolog/plopinvert').
:- use_module(engine).
title('plopinvert').
f_g(N, F) :- Top is N - 1, rnd_int(0, Top, I), rnd_int(0, Top, J), rnd_int(1, 9, D), rnd_pick([in(I), shift(I, D), plus(I, J), const(D)], F).
prog_g(N, Fs) :- rnd_int(1, 5, M), length(Fs, M), maplist(f_g(N), Fs).
str_g(N, S) :- length(S, N), maplist([X]>>rnd_int(0, 9, X), S).
case(invert, [Fs, N, W], invert) :- rnd_int(1, 3, N), prog_g(N, Fs), str_g(N, In), ( rnd_chance(80) -> run(Fs, In, W) ; length(Fs, L), str_g(L, W) ).
case(count, [Fs, N, W], count) :- rnd_int(1, 3, N), prog_g(N, Fs), str_g(N, In), run(Fs, In, W).
