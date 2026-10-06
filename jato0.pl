% Jato 0
:- module(jato0, [obter_controles/4]).

%% Explicacao:
% Informacao:
%   X: posição horizontal do jato
%   Y: posiçao vertical do jato
%   ANGLE: angulo de inclinacao do jato: 0 para virado para frente até PI*2 (~6.28)
%   SCORE: inteiro com a "vida" do jato. Em zero, ele perdeu
%   SPEED: velocidade do jato
% Adversarios:
%   vetor com a posicao de todos os adversarios, [ [X1,Y1], [X2,Y2], ... ]
% Misseis:
%   vetor com a posicao de todos os misseis, [ [X1,Y1], [X2,Y2], ... ]
% Controles:
%   FORWARD: 1 para acelerar e 0 para continuar a velocidade atual
%   REVERSE: 1 para desacelerar e 0 para continuar a velocidade atual
%   LEFT: 1 para ir pra esquerda e 0 para não ir
%   RIGHT: 1 para ir pra direita e 0 para não ir
%   BOOM: 1 para tentar disparar (BOOM). Obs.: ele só pode disparar uma bala a cada segundo
%   MSG: mensagem para DEBUG

%%% Faça seu codigo a partir daqui, sendo necessario sempre ter o predicado:
%%%% obter_controles([X,Y,ANGLE,SCORE,SPEED], ADVERSARIOS, MISSEIS, [FORWARD, REVERSE, LEFT, RIGHT, BOOM, MSG]) :- ...

troca(0, 1).
troca(1, 0).

% [FORWARD, REVERSE, LEFT, RIGHT, BOOM, MSG]
obter_controles(INFORMACAO, ADVERSARIOS, MISSEIS, CONTROLES) :-
    INFORMACAO = [X, Y, ANGLE, SCORE, SPEED],
    CONTROLES = [FORWARD, REVERSE, LEFT, RIGHT, BOOM, MSG],
    random_between(0,1,AA),
    troca(AA, BB),
    random_between(0,1,CC),
    FORWARD is AA,
    REVERSE is 0,
    LEFT is AA,
    RIGHT is BB,
    BOOM is CC,
    MSG = "Regra padrao aplicada".
    %opcao:
    %term_string([ADVERSARIOS| [MISSEIS]], MSG).

% Para evitar erros, o jato para:
obter_controles(_, _, _, [0,0,0,0,0,"nenhuma regra aplicada"]).

% Dica:
% Você pode transformar um vetor com qualquer coisa para string assim:
% term_string(VETOR, MSG).
% Assim, MSG passa a ser uma string do seu vetor
% Ex.:
% ?- term_string([1,2,"teste",oi], MSG.
% MSG = "[1,2,\"teste\",oi]".

%================================================================================================
%====================================== IA Bravely Default ======================================
%================================================================================================

%funcao de fazer pitagoras para calcular distancias em um plano bidimensional
%nem tira a raiz quadrada pq n faz diferenca
pitagoras(DeltaX,DeltaY,Distancia):-
Distancia is DeltaX*DeltaX+DeltaY*DeltaY.

%================================================================================================

%funcao para calcular menor de 2 numeros
%A é menor
menor(A,B,MenorNum):-
A=<B,
MenorNum is A.

%B é menor
menor(A,B,MenorNum):-
B<A,
MenorNum is B.

%================================================================================================

%funcao para calcular distancias toroidais
distanciaToroidal(Xplayer,Yplayer,Xinimigo,Yinimigo,Distancia):-
DeltaX is abs(Xplayer-Xinimigo),
DeltaY is abs(Yplayer-Yinimigo),
Largura is 1024,
Altura is 768,
DeltaToroidalX is Largura-DeltaX,
DeltaToroidalY is Altura-DeltaY,
menor(DeltaX,DeltaToroidalX,MenorX),
menor(DeltaY,DeltaToroidalY,MenorY),
pitagoras(MenorX,MenorY,Distancia).

%================================================================================================

%funcao para calcular a distancia toroidal entre o player e um inimigo
distanciaInimigo(Xplayer,Yplayer,[Xinimigo,Yinimigo],Distancia):-
distanciaToroidal(Xplayer,Yplayer,Xinimigo,Yinimigo,Distancia).

%================================================================================================

%funcao para criar uma lista com distancias de todos os inimigos
%lista não vazia
listaDistancias(Xplayer,Yplayer,[[Xinimigo,Yinimigo]|Cauda],Distancias):-
distanciaInimigo(Xplayer,Yplayer,[Xinimigo,Yinimigo],Distancia),
Distancias = [[[Xinimigo,Yinimigo],Distancia]|DistanciasCauda],
listaDistancias(Xplayer,Yplayer,Cauda,DistanciasCauda).

%lista vazia
listaDistancias(_,_,[],[]).

%================================================================================================

%funcao para achar o aviao mais proximo da lista
%caso tenha mais de 1 e MenorDaCauda seja menor que MenorDist
acharMaisProx([[[Xinimigo,Yinimigo],Distancia]|Cauda],MenorDist,Xmenor,Ymenor):-
acharMaisProx(Cauda,MenorDaCauda,XmenorCauda,YmenorCauda),
MenorLocal is Distancia,
Xlocal is Xinimigo,
Ylocal is Yinimigo,
MenorDaCauda =< MenorLocal,
MenorDist is MenorDaCauda,
Xmenor is XmenorCauda,
Ymenor is YmenorCauda.

%caso tenha mais de 1 e MenorDaCauda seja maior que MenorDist
acharMaisProx([[[Xinimigo,Yinimigo],Distancia]|Cauda],MenorDist,Xmenor,Ymenor):-
acharMaisProx(Cauda,MenorDaCauda,XmenorCauda,YmenorCauda),
MenorLocal is Distancia,
Xlocal is Xinimigo,
Ylocal is Yinimigo,
MenorDaCauda > MenorLocal,
MenorDist is MenorLocal,
Xmenor is Xlocal,
Ymenor is Ylocal.

%caso seja o único o com menor distancia é ele
acharMaisProx([[[Xinimigo,Yinimigo],Distancia]],MenorDist,Xmenor,Ymenor):-
MenorDist is Distancia,
Xmenor is Xinimigo,
Ymenor is Yinimigo.

%================================================================================================

%funcao para achar angulo entre o player e um inimigo
acharAnguloRelativo(Xplayer,Yplayer,[[[Xinimigo,Yinimigo],Distancia]],Angulo):-
DistanciaX is abs(Xplayer-Xinimigo),
DistanciaY is abs(Yplayer-Yinimigo),
DistanciaRealX is (Xplayer-Xinimigo),%DistanciaReal será usado para descobrir o quadrante dos graus
DistanciaRealY is (Yplayer-Yinimigo),
CosAngulo is (DistanciaX*DistanciaX+DistanciaY*DistanciaY-Distancia*Distancia)/(2*DistanciaX*Distancia),
Angulo is acos(CosAngulo).