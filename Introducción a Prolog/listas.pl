% Listas en Prolog
% Tomar el primer elemento de una lista
primero([Cabeza|_],Cabeza).

% Tomar el segundo elemento de una lista
segundo([_,Seg|_],Seg).

% Tomar el último elemento de una lista
ultimo([Ult],Ult). % Caso base: si la lista tiene un solo elemento, ese es el último
ultimo([_|Cola],Ult) :- ultimo(Cola,Ult). % Caso recursivo: ignorar la cabeza y buscar el último en la cola

% Tomar el penúltimo elemento de una lista--> Como lo construyo?


% Tomar cualquier elemento de la lista -->Anuncia un True si esta el miembro
miembro(X,[X|_]). % Caso base: esta de primero en la lista
miembro(X,[_|Cola]):- miembro(X,Cola). % Caso rcursivo: el caso recursivo toma la cola y la envia al caso base
