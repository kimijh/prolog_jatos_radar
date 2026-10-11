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
    contaInimigos(ADVERSARIOS, QntsVivos),
    defineEstado(QntsVivos, EstadoPlayer, MSG),
    lidarComInimigoMaisProx(
        EstadoPlayer, X, Y, ANGLE, ADVERSARIOS,
        Xmenor, Ymenor, MenorDist, Angulo, LEFT, RIGHT, BOOM
    ),
    FORWARD is 1,
    REVERSE is 0,
    CONTROLES = [FORWARD, REVERSE, LEFT, RIGHT, BOOM, MSG].

% Dica:
% Você pode transformar um vetor com qualquer coisa para string assim:
% term_string(VETOR, MSG).
% Assim, MSG passa a ser uma string do seu vetor
% Ex.:
% ?- term_string([1,2,"teste",oi], MSG.
% MSG = "[1,2,\"teste\",oi]".

%===========================================================================================================
%====================================== Funcoes Necessárias Para a IA ======================================
%===========================================================================================================

%funcao de fazer pitagoras para calcular distancias em um plano bidimensional
pitagoras(DeltaX,DeltaY,Distancia):-
Distancia is sqrt(DeltaX*DeltaX+DeltaY*DeltaY).

%===========================================================================================================

%funcao para calcular menor de 2 numeros
%A é menor
menor(A,B,MenorNum):-
A=<B,
MenorNum is A.

%B é menor
menor(A,B,MenorNum):-
B<A,
MenorNum is B.

%===========================================================================================================

%funcao para calcular menor do absoluto de 2 numeros
%A é menor
menorAbs(A,B,MenorNum):-
AbsA is abs(A),
AbsB is abs(B),
AbsA=<AbsB,
MenorNum is A.

%B é menor
menorAbs(A,B,MenorNum):-
AbsA is abs(A),
AbsB is abs(B),
AbsB<AbsA,
MenorNum is B.

%===========================================================================================================

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

%===========================================================================================================

%funcao para calcular a distancia toroidal entre o player e um inimigo
distanciaInimigo(Xplayer,Yplayer,[Xinimigo,Yinimigo],Distancia):-
distanciaToroidal(Xplayer,Yplayer,Xinimigo,Yinimigo,Distancia).

%===========================================================================================================

%funcao para criar uma lista com distancias de todos os inimigos
%lista não vazia
listaDistancias(Xplayer,Yplayer,[[Xinimigo,Yinimigo]|Cauda],Distancias):-
distanciaInimigo(Xplayer,Yplayer,[Xinimigo,Yinimigo],Distancia),
Distancias = [[[Xinimigo,Yinimigo],Distancia]|DistanciasCauda],
listaDistancias(Xplayer,Yplayer,Cauda,DistanciasCauda).

%lista vazia
listaDistancias(_,_,[],[]).

%===========================================================================================================

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

%===========================================================================================================

%funcao para achar a direcao do angunlo, todas as possibilidades, player esta a direita/esquerda e em cima/baixo do inimigo
%no momento tem 4 delas pra cada possibilidade, refatorar depois pois isso tá muito feio eu quero ser um programador foda
%DIREITA/CIMA
deslocamentoToroidal(Xplayer,Yplayer,Xinimigo,Yinimigo,DeltaX,DeltaY):-
Xplayer>=Xinimigo,
Yplayer>=Yinimigo,
ProvisorioX1 is (Xplayer-Xinimigo),
ProvisorioY1 is (Yplayer-Yinimigo),
ProvisorioX2 is (-1)*((1024 - Xplayer) + Xinimigo),
ProvisorioY2 is (-1)*((768-Yplayer)+Yinimigo),
menorAbs(ProvisorioX1,ProvisorioX2,DeltaX),
menorAbs(ProvisorioY1,ProvisorioY2,DeltaY).

%DIREITA/BAIXO
deslocamentoToroidal(Xplayer,Yplayer,Xinimigo,Yinimigo,DeltaX,DeltaY):-
Xplayer>=Xinimigo,
Yplayer<Yinimigo,
ProvisorioX1 is (Xplayer-Xinimigo),
ProvisorioY1 is (Yplayer-Yinimigo),
ProvisorioX2 is (-1)*((1024 - Xplayer) + Xinimigo),
ProvisorioY2 is (768-Yinimigo)+Yplayer,
menorAbs(ProvisorioX1,ProvisorioX2,DeltaX),
menorAbs(ProvisorioY1,ProvisorioY2,DeltaY).

%ESQUERDA/CIMA
deslocamentoToroidal(Xplayer,Yplayer,Xinimigo,Yinimigo,DeltaX,DeltaY):-
Xplayer<Xinimigo,
Yplayer>=Yinimigo,
ProvisorioX1 is (Xplayer-Xinimigo),
ProvisorioY1 is (Yplayer-Yinimigo),
ProvisorioX2 is (1024-Xinimigo)+Xplayer,
ProvisorioY2 is (-1)*((768-Yplayer)+Yinimigo),
menorAbs(ProvisorioX1,ProvisorioX2,DeltaX),
menorAbs(ProvisorioY1,ProvisorioY2,DeltaY).

%ESQUERDA/BAIXO
deslocamentoToroidal(Xplayer,Yplayer,Xinimigo,Yinimigo,DeltaX,DeltaY):-
Xplayer<Xinimigo,
Yplayer<Yinimigo,
ProvisorioX1 is (Xplayer-Xinimigo),
ProvisorioY1 is (Yplayer-Yinimigo),
ProvisorioX2 is (1024-Xinimigo)+Xplayer,
ProvisorioY2 is (768-Yinimigo)+Yplayer,
menorAbs(ProvisorioX1,ProvisorioX2,DeltaX),
menorAbs(ProvisorioY1,ProvisorioY2,DeltaY).

%===========================================================================================================

%funcao para normalizar angulos para o padrão do jogo
%angulo é negativo
normalizarAngulo(Angulo, AnguloNormalizado):-
Angulo<0,
AnguloNormalizado is Angulo + 2*pi.

%angulo é positivo
normalizarAngulo(Angulo, AnguloNormalizado):-
Angulo>=0,
AnguloNormalizado is Angulo.

%===========================================================================================================

%funcao que converte o angulo obtido pelo atan2 para o sistema de angulos do jogo
calcularAngulo(DeltaX,DeltaY,Angulo):-
AnguloProvisorio1 is atan2(DeltaY,DeltaX),
AnguloProvisorio2 is AnguloProvisorio1 + (pi/2),
normalizarAngulo(AnguloProvisorio2, AnguloNormalizado),
Angulo is AnguloNormalizado.

%===========================================================================================================

%funcao para obter angulo de um inimigo em relacao ao jogador considerando a arena toroidal
calcularAnguloInimigo(Xplayer,Yplayer,Xinimigo,Yinimigo,Angulo):-
deslocamentoToroidal(Xplayer,Yplayer,Xinimigo,Yinimigo,DeltaX,DeltaY),
calcularAngulo(DeltaX,DeltaY,Angulo).

%===========================================================================================================

%funcao para achar qual o menor giro que o player deve realizar para apontar para o inimigo
diferencaAngulo(AnguloPlayer,AnguloInimigo,AngMenor):-
Ang1 is (AnguloInimigo-AnguloPlayer),
Ang2 is Ang1-(2*pi),
Ang3 is Ang1+(2*pi),
menorAbs(Ang1,Ang2,AngMenor1),
menorAbs(AngMenor1,Ang3,AngMenor).

%===========================================================================================================

%funcao para descobrir como atualizar o angulo
%D>0 aumenta o angulo -> LEFT
%D<0 diminui o angulo -> RIGHT
%D==0 faz nada
%Diferenca>0
direcaoAngulo(Diferenca,Direcao):-
Diferenca>0,
Direcao="LEFT".
%Diferenca<0
direcaoAngulo(Diferenca,Direcao):-
Diferenca<0,
Direcao="RIGHT".
%Diferenca=0
direcaoAngulo(Diferenca,Direcao):-
Diferenca=:=0,
Direcao="NONE".

%===========================================================================================================

%funcao para decidir como atualizar o angulo
%Direcao=LEFT
decideDirecao(Direcao,LEFT,RIGHT):-
Direcao="LEFT",
LEFT is 1,
RIGHT is 0.
%Direcao=RIGHT
decideDirecao(Direcao,LEFT,RIGHT):-
Direcao="RIGHT",
LEFT is 0,
RIGHT is 1.
%Direcao=NONE
decideDirecao(Direcao,LEFT,RIGHT):-
Direcao="NONE",
LEFT is 0,
RIGHT is 0.

%===========================================================================================================

%funcao que encontra o inimigo mais proximo e retorna sua posicao, distancia e angulo
analisarInimigoMaisProx(Xplayer,Yplayer,ListaInimigos,Xmenor,Ymenor,MenorDist,Angulo):-
listaDistancias(Xplayer,Yplayer,ListaInimigos,Distancias),
acharMaisProx(Distancias,MenorDist,Xmenor,Ymenor),
calcularAnguloInimigo(Xplayer,Yplayer,Xmenor,Ymenor,Angulo).

%===========================================================================================================

%funcao que determina qual estado o player deve estar, estado é o que controla seu comportamento
%dois vivos ou menos, fica BRAVE
defineEstado(QntsVivos,EstadoPlayer,MSG):-
QntsVivos=<2,
MSG = "Estou BRAVE!",
EstadoPlayer = "BRAVE".

%mais de dois vivos, fica DEFAULT
defineEstado(QntsVivos,EstadoPlayer,MSG):-
QntsVivos>2,
MSG = "Estou DEFAULT...",
EstadoPlayer = "DEFAULT".

%===========================================================================================================

%funcao que conta quantos inimigos estao vivos atualmente
%tem proxima casa
contaInimigos([Cabeca|Cauda],QntsVivos):-
contaInimigos(Cauda,ContadorLocal),
QntsVivos is ContadorLocal + 1.

%nao tem proxima casa, lista chegou ao fim
contaInimigos([],QntsVivos):-
QntsVivos is 0.

%===========================================================================================================

%funcao que decide o que fazer com o inimigo mais proximo dependendo do estado atual do player, BRAVE ou DEFAULT
%caso esteja no estado BRAVE e esteja perto o suficiente para um tiro certeiro
lidarComInimigoMaisProx(EstadoPlayer,Xplayer,Yplayer,AnguloPlayer,ListaInimigos,Xmenor,Ymenor,MenorDist,Angulo,LEFT,RIGHT,BOOM):-
EstadoPlayer="BRAVE",
analisarInimigoMaisProx(Xplayer,Yplayer,ListaInimigos,Xmenor,Ymenor,MenorDist,Angulo),
MenorDist<=100,
BOOM is 1,
diferencaAngulo(AnguloPlayer,Angulo,AngMenor),
direcaoAngulo(AngMenor,Direcao),
decideDirecao(Direcao,LEFT,RIGHT).

%caso esteja no estado BRAVE porém nao perto o suficiente
lidarComInimigoMaisProx(EstadoPlayer,Xplayer,Yplayer,AnguloPlayer,ListaInimigos,Xmenor,Ymenor,MenorDist,Angulo,LEFT,RIGHT,BOOM):-
EstadoPlayer="BRAVE",
analisarInimigoMaisProx(Xplayer,Yplayer,ListaInimigos,Xmenor,Ymenor,MenorDist,Angulo),
MenorDist>100,
BOOM is 0,
diferencaAngulo(AnguloPlayer,Angulo,AngMenor),
direcaoAngulo(AngMenor,Direcao),
decideDirecao(Direcao,LEFT,RIGHT).

%caso esteja no estado DEFAULT
lidarComInimigoMaisProx(EstadoPlayer,Xplayer,Yplayer,AnguloPlayer,ListaInimigos,Xmenor,Ymenor,MenorDist,Angulo,LEFT,RIGHT,BOOM):-
EstadoPlayer="DEFAULT",
BOOM is 1,
analisarInimigoMaisProx(Xplayer,Yplayer,ListaInimigos,Xmenor,Ymenor,MenorDist,Angulo),
diferencaAngulo(AnguloPlayer,Angulo,AngMenor),
direcaoAngulo(AngMenor,Direcao),
decideDirecao(Direcao,RIGHT,LEFT).%RIGHT e LEFT trocados pq queremos virar para longe do inimigo, nao exatamente pro oposto, só manter distancia