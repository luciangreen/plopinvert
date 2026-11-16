% Theorems, proved by exhaustion. Run: swipl -g main -t halt proofs/theorems.pl
:- module(theorems, [main/0]).
:- use_module(prove).
:- discontiguous theorem/1.
:- use_module(library(lists)).
:- use_module(library(apply)).
main :- prove_all(theorems).
:- use_module('../prolog/plopinvert').

% Domain: every 2-character program from a pool, inputs of length 2 over 0..9, every reachable and some unreachable outputs.
formula(F) :- member(F, [in(0), in(1), shift(0, 1), plus(0, 1), plus(1, 1), const(3)]).
prog(Fs) :- length(Fs, 2), maplist(formula, Fs).
str(S) :- length(S, 2), maplist([X]>>between(0, 9, X), S).
wanted(Fs, W) :- ( str(In), run(Fs, In, W) ; W = [0, 0] ; W = [3, 9] ).

% 1. Sound: every input found gives the wanted output (whatever is put in its free places).
theorem(found_inputs_give_the_output) :- forall(( prog(Fs), wanted(Fs, W), invert(Fs, 2, W, Ins), member(In, Ins) ), forall(maplist([X]>>(nonvar(X) -> true ; member(X, [0, 9])), In), run(Fs, In, W))).

% 2. Complete: the count matches trying every input.
theorem(count_matches_brute_force) :- forall(( prog(Fs), member(W, [[0, 0], [3, 3], [1, 2], [9, 9]]) ), ( count(Fs, 2, W, C), brute(Fs, 2, W, B), length(B, C) )).

% 3. An output that nothing gives has no inputs.
theorem(impossible_outputs_have_none) :- forall(( prog(Fs), member(W, [[0, 0], [3, 3], [1, 2]]), brute(Fs, 2, W, []) ), invert(Fs, 2, W, [])).

% 4. Positions no character reads are always left free.
theorem(unread_positions_free) :- forall(( member(Fs, [[in(0), const(3)], [const(1), shift(0, 2)]]), str(In), run(Fs, In, W), invert(Fs, 2, W, Ins), member(I, Ins) ), ( nth0(1, I, X), var(X) )).
