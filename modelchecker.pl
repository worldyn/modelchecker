% Created by Adam Jacobs
% November 2017

% Check if a list is not empty
notEmpty([_|_]).

% Load model, initial state and formula from file.
verify(Input) :-
  see(Input), read(T), read(L), read(S), read(F), seen,
  check(T, L, S, [], F).

% check(T, L, S, U, F)
% T - The transitions in form of adjacency lists
% L - The labeling
% S - Current state
% U - Currently recorded states
% F - CTL Formula to check.
%
% Should evaluate to true iff the sequent below is valid.
%
% (T,L), S |- F
% U
% See tests folder for example input
% To execute: consult(’modelchecker.pl’). verify(’input.txt’).
% Literals
check(_, L, S, _, X) :- member([S, Vars], L), member(X, Vars).
check(_, L, S, _, neg(X)) :- member([S, Vars], L), \+ member(X, Vars).
% And
check(T, L, S, U, and(F,G)) :- check(T, L, S, U, F), check(T, L, S, U, G).
% Or
check(T, L, S, U, or(F,G)) :- check(T, L, S, U, F) ; check(T, L, S, U, G).
% AX
check(T, L, S, U, ax(F)) :-
  member([S, NextStates], T), !,
  forall(member(SN, NextStates), check(T, L, SN, U, F)).
% EX
check(T, L, S, U, ex(F)) :-
  member([S, NextStates], T), !,
  member(SN, NextStates), check(T, L, SN, U, F), !.
% AG
check(_, _, S, U, ag(_)) :-
  member(S, U), !.
check(T, L, S, U, ag(F)) :-
  member([S, NextStates], T), !,
  forall(member(SN, NextStates), check(T, L, SN, [S|U], ag(F))).
% EG
check(_, _, S, U, eg(_)) :-
  member(S, U), !.
check(T, L, S, U, eg(F)) :-
  check(T, L, S, U, F), !,
  member([S, NextStates], T), !,
  member(SN, NextStates), check(T, L, SN, [S|U], eg(F)), !.
% EF
check(T, L, S, U, ef(F)) :-
  \+ member(S, U), !,
  (
    check(T, L, S, U, F), !
  ) ;
  (
    member([S, NextStates], T), !,
    member(SN, NextStates), check(T, L, SN, [S|U], ef(F)), !
  ).

% AF
check(T, L, S, U, af(F)) :-
  \+ member(S, U), !,
  (
    check(T, L, S, U, F), !
  ) ;
  (
    member([S, NextStates], T), !,
    forall(member(SN, NextStates), check(T, L, SN, [S|U], af(F)))
  ).
