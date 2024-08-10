/*
Gestionar una cárcel no es tarea fácil y para lograrlo requerimos la ayuda de un programa en
Prolog. Se cuenta con la siguiente base de conocimiento, que contiene información acerca de
varias cárceles y qué personas residen allí: tanto guardias como prisioneros.
De los guardias sabemos su nombre y de los prisioneros, su nombre y los crímenes que
cometieron. Se contemplan tres tipos de crímenes:

● Homicidio, que registra la víctima.
● Narcotráfico, que indica la lista de drogas traficadas.
● Robo, que relaciona cuánto dinero en dólares fue robado.
*/

% guardia(Nombre)
guardia(bennett).
guardia(mendez).
guardia(george).

% prisionero(Nombre, Crimen)
prisionero(piper, narcotrafico([metanfetaminas])).
prisionero(alex, narcotrafico([heroina])).
prisionero(alex, homicidio(george)).
prisionero(red, homicidio(rusoMafioso)).
prisionero(suzanne, robo(450000)).
prisionero(suzanne, robo(250000)).
prisionero(suzanne, robo(2500)).
prisionero(dayanara, narcotrafico([heroina, opio])).
prisionero(dayanara, narcotrafico([metanfetaminas])).

/*
1. Dado el predicado controla/2:
*/

% controla(Controlador, Controlado)
controla(piper, alex).
controla(bennett, dayanara).
controla(Guardia, Otro):- 
    guardia(Guardia),
    prisionero(Otro,_), 
    not(controla(Otro, Guardia)).

% Indicar, justificando, si es inversible y, en caso de no serlo, dar ejemplos de las
% consultas que NO podrían hacerse y corregir la implementación para que se pueda.

% El predicado no es inversible si se consulta por los Guardias que controlan a un prisionero.
% (cuando entran al not, el programa no es capaz de decirme los casos donde no ocurre que un preso controla a un guardia ya que no sabe cuales son todos los guardias).
% Tambien ocurre que piper (preso) controla a alex (otro preso) a pesar de no ser piper un guardia.

/*
2. conflictoDeIntereses/2: relaciona a dos personas distintas (ya sean guardias o prisioneros) si 
no se controlan mutuamente y existe algún tercero al cual ambos controlan.
*/

conflictoDeIntereses(Persona, OtraPersona):-
    controla(Persona, Tercero),
    controla(OtraPersona, Tercero),
    not(controla(Persona, OtraPersona)),
    not(controla(OtraPersona, Persona)),
    Persona \= OtraPersona.

/*
3. peligroso/1: Se cumple para un preso que sólo cometió crímenes graves.
Un robo nunca es grave.
Un homicidio siempre es grave.
Un delito de narcotráfico es grave cuando incluye al menos 5 drogas a la vez, o incluye metanfetaminas.
*/

peligroso(Preso):-
    prisionero(Preso, _),
    forall(prisionero(Preso, Delito), esGrave(Delito)).

esGrave(homicidio(_)).

esGrave(narcotrafico(Drogas)):-
    length(Drogas, Cantidad),
    Cantidad >= 5.

esGrave(narcotrafico(Drogas)):-
    member(metanfetaminas,Drogas).

/*
4. ladronDeGuanteBlanco/1: Aplica a un prisionero si sólo cometió robos y todos fueron por más de $100.000.
*/

ladronDeGuanteBlanco(Preso):-
    prisionero(Preso, _),
    forall(prisionero(Preso, Delito), granRobo(Delito)).

granRobo(robo(Cantidad)):-
    Cantidad > 100000.

/*
5. condena/2: Relaciona a un prisionero con la cantidad de años de condena que debe cumplir. 
Esto se calcula como la suma de los años que le aporte cada crimen cometido, que se obtienen de la siguiente forma:
La cantidad de dinero robado dividido 10.000.
7 años por cada homicidio cometido, más 2 años extra si la víctima era un guardia.
2 años por cada droga que haya traficado.
*/

/*
condenaPorRobo(Preso, Condena):-
    findall(DineroRobado, prisionero(Preso, robo(DineroRobado)), ListaRobos),
    sumlist(ListaRobos, TotalRobado),
    Condena is TotalRobado // 10000.

condenaPorHomicidio(Preso, Condena):-
    findall(Asesinado, (prisionero(Preso, homicidio(Asesinado))), Asesinados),
    length(Asesinados, CantidadDeAsesinados),
    findall(Guardia, (prisionero(Preso, homicidio(Guardia)), guardia(Guardia)), GuardiasAsesinados),
    length(GuardiasAsesinados, CantidadDeGuardiasAsesinados),
    Condena is CantidadDeAsesinados * 7 + CantidadDeGuardiasAsesinados * 2.

condenaPorNarcotrafico(Preso, Condena):-
    prisionero(Preso, narcotrafico(Drogas)),
    length(Drogas, CantidadDeDrogasTraficadas),
    Condena is CantidadDeDrogasTraficadas * 2.
*/

pena(robo(Monto), Pena):-
    Pena is Monto / 10000.

pena(homicidio(Persona), 9):-
    guardia(Persona).

pena(homicidio(Persona), 7):-
    not(guardia(Persona)).

pena(narcotrafico(Drogas), Pena):-
    length(Drogas, Cantidad),
    Pena is Cantidad * 2.

condena(Preso, Condena):-
    prisionero(Preso, _),
    findall(Pena, (prisionero(Preso, Delito), pena(Delito, Pena)), Penas),
    sumlist(Penas, Condena).

/*
6. capoDiTutiLiCapi/1: Se dice que un preso es el capo de todos los capos cuando nadie lo controla, 
pero todas las personas de la cárcel (guardias o prisioneros) son controlados por él, o por alguien a quien él controla (directa o indirectamente).
*/

personaDeCarcel(Persona):-
    prisionero(Preso, _).
personaDeCarcel(Persona):-
    guardia(Persona).

capoDiTutiLiCapi(Preso):-
    prisionero(Preso, _),
    not(controla(_, Preso)),
    forall(personaDeCarcel(Persona), controlaDirecOIndirectamente(Preso, Persona)).

controlaDirecOIndirectamente(Uno, Otro):-
    controla(Uno, Otro).

controlaDirecOIndirectamente(Uno, Otro):-
    controla(Uno, Tercero),
    controlaDirecOIndirectamente(Tercero, Otro).

