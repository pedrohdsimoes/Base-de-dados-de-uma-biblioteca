-module(biblio).
-import(lists, [foreach/2]).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").

-record(pessoa, {id, nome, morada, telefone}).
-record(livro, {id, nome, autores}).
-record(requisicao, {pessoa, livro}).

do_this_once() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
    mnesia:create_table(pessoa, [{attributes, record_info(fields, pessoa)}]),
    mnesia:create_table(livro,  [{attributes, record_info(fields, livro)}]),
    mnesia:create_table(requisicao, [{attributes, record_info(fields, requisicao)}]),
    mnesia:stop().

start() ->
    mnesia:start(),
    mnesia:wait_for_tables([pessoa,livro,requisicao], 20000).

reset_tables() ->
    mnesia:clear_table(pessoa),
    mnesia:clear_table(livro),
       mnesia:clear_table(requisicao),
    F = fun() ->
		    foreach(fun mnesia:write/1, example_tables())
	  end,
    mnesia:transaction(F).

do(Q) ->
    F = fun() -> qlc:e(Q) end,
    {atomic, Val} = mnesia:transaction(F),
    Val.

%%----------------------------- LOOKUP -------------------------------%%

%%  livros: dado um número de cartão de cidadão determina 
%%          a lista de livros requisitados por essa pessoa;

%% SQL equivalent
%%   SELECT livro.nome
%%   FROM livro, requisicao
%%   WHERE livro.id contido em requisicao.livro 
%%   AND requisicao.pessoa = Cidadao

livros(Cidadao) ->
    do(qlc:q([X#livro.nome || X <- mnesia:table(livro),
                 Y <- mnesia:table(requisicao),
			     lists: member(X#livro.id , Y#requisicao.livro) =:= true,
                 Y#requisicao.pessoa =:= Cidadao
				])).


%%  empréstimos: dado o título de um livro determina a lista
%%               de pessoas que requisitaram esse livro;

%% SQL equivalent
%%   SELECT pessoa.nome
%%   FROM pessoa, livro, requisicao
%%   WHERE livro.id contido em pessoa.livro
%%   AND requisicao.pessoa = pessoa.id
%%   AND livro.nome = Titulo

%% lists:member verifica se um elemento está dentro de uma lista (boleano)

emprestimos(Titulo) ->
    do(qlc:q([X#pessoa.nome || X <- mnesia:table(pessoa),
                 Y <- mnesia:table(livro),
                 Z <- mnesia:table(requisicao),
                lists: member(Y#livro.id,Z#requisicao.livro) =:= true,
                Z#requisicao.pessoa =:= X#pessoa.id,
                 Y#livro.nome =:= Titulo
				])).


%%  requisitado: dado o código de um livro determina se 
%%               o livro está requisitado (retorna um booleano);

%% SQL equivalent
%% SELECT requisicao.livro
%% FROM requisicao
%% WHERE Codigo contido em Requisitado

%% lists: append torna uma lista de listas numa lista

requisitado(Codigo) ->
        Requisitado = lists: append( 
        do(qlc:q([X#requisicao.livro || X <- mnesia:table(requisicao)
				]))),
        lists: member(Codigo,Requisitado).


%%  códigos: dado o título de um livro retorna a lista 
%%           de códigos de livros com esse título;

%% SQL equivalent
%%   SELECT livro.id
%%   FROM livro
%%   WHERE livro.nome = "Titulo"

codigos(Titulo) ->
    do(qlc:q([X#livro.id || X <- mnesia:table(livro),
                 X#livro.nome =:= Titulo
				])).


%%  numrequisicões: dado um número de cartão de cidadão retorna o 
%%                  número de livros requisitados por essa pessoa;

%% SQL equivalent
%%   SELECT requisicao.livro
%%   FROM requisicao
%%   WHERE requisicao.pessoa = Cidadao

numRequisicoes(Cidadao) ->
    Requisicoes = lists: append(
        do(qlc:q([X#requisicao.livro || X <- mnesia:table(requisicao),
                 X#requisicao.pessoa =:= Cidadao
				]))
                ),
   length(Requisicoes).

%%----------------------------- UPDATE -------------------------------%%

add_requisicao(IDp, IDl) ->
    LivrosRequisitados = lists: append(
        do(qlc:q([X#requisicao.livro || X <- mnesia:table(requisicao),
        X#requisicao.pessoa =:= IDp
        ]))
    ),
    Requisitar = #requisicao{pessoa=IDp,livro=LivrosRequisitados++IDl}, 
    F = fun() ->
		mnesia:write(Requisitar)
	end,
    mnesia:transaction(F).

remove_requisicao(IDp, IDl) ->
     LivrosRequisitados = lists: append(
        do(qlc:q([X#requisicao.livro || X <- mnesia:table(requisicao),
        X#requisicao.pessoa =:= IDp
        ]))
    ),
    Devolver = #requisicao{pessoa=IDp,livro=LivrosRequisitados--IDl}, 
    F = fun() ->
		mnesia:write(Devolver)
	end,
    mnesia:transaction(F).

%%----------------------------- EXAMPLE -------------------------------%%

example_tables() ->
    [%% pessoas
     {pessoa, 1, "António", "Rua das Macacas", 923030495},
     {pessoa, 2, "Almiro", "Rua das Alperces", 914030287},
     {pessoa, 3, "Amélia", "Rua dos Rochedos", 962030298},
     {pessoa, 4, "Camilo", "Rua da Constituição 2023", 934987947},
     {pessoa, 5, "Fernando", "Rua Príncipe Perfeito", 913726347},
     %% livros
     {livro, 2001, "Personal Account of the Everest Disaster",[ "Jon Krakauer"]},
     {livro, 2002, "Personal Account of the Everest Disaster",[ "Jon Krakauer"]},
     {livro, 2003, "The Fellowship of the Ring", ["J.R.R. Tolkien"]},
     {livro, 2004, "The Fellowship of the Ring", ["J.R.R. Tolkien"]},
     {livro, 2005, "The Fellowship of the Ring", ["J.R.R. Tolkien"]},
     {livro, 2006,"Harry Potter and the Goblet of Fire", ["J.K.Rolling"]},
     {livro, 2007,"Harry Potter and the Cursed Child", ["J.K.Rolling"]},
     {livro, 2008, "The Autobiography of Henry VIII", ["Margaret George"]},
     {livro, 2009,"Harry Potter and the Chamber of Secrets", ["J.K.Rolling"]},
     {livro, 2010,"Harry Potter and the Philosopher's Stone", ["J.K.Rolling"]},
     % requisições
     {requisicao, 1, [2001,2006]},
     {requisicao, 2, [2004]},
     {requisicao, 3, [2005]},
     {requisicao, 4, [2008,2007,2002]}
    ].



