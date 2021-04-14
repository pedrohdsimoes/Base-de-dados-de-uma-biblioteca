# Base-de-dados-de-uma-biblioteca

## Objetivos e Descrição top-level do programa

O objetivo deste trabalho consiste em criar um programa Erlang, de forma a implementar um servidor correspondente a uma estrutura de dados/ base de dados de uma biblioteca, onde são guardadas todas as requisições de livros pelas pessoas. 
Foi-nos imposto o requisito da estrutura guardar requisições como pares de identificadores de pessoas e dos livros requisitados pela respetiva pessoa.
 De tal forma, a implementação fica dividida em duas partes: mensagens de lookup e mensagens de update. Nas mensagens de lookup, é suposto fazer uma “pergunta” ao servidor e obter uma resposta enquanto cliente ,sobre a base de dados. Para isso foram implementadas as funções livros que recebe como argumento o número de cartão de cidadão da pessoa (Cidadao), emprestimos que recebe como argumento o título de um livro (Titulo), requisitado que recebe como argumento o código de um livro (Codigo), codigo que recebe como argumento o título de um livro (Titulo) e numRequisicoes  que recebe como argumento o número de cartão de cidadão da pessoa (Cidadao). Já nas mensagens de update, é suposto atualizar a base de dados com base na função utilizada. Sendo possível adicionar à base de dados, o par {pessoa, livros} com a função add_requisicao e remover o mesmo com a função remove_requisicao.
	A função do_this_once  cria as tabelas(pessoa, livro e requisicao), start prepara o programa e espera pelas tabelas e reset_tables limpa as tabelas.


## Exemplos de aplicação do programa

Para utilizar este programa, deve-se começar por compila-lo no terminal, escrevendo primeiro “erl” que abre o compilador de erlang e de seguida “c(biblio).”  que compila o programa.
A primeira função a ser corrida deve ser a “biblio:do_this_once” , de seguida  “biblio:start().” e depois “biblio:reset_tables().”.
	A partir deste momento, o programa está pronto a ser testado e pode mandar ao servidor mensagens de lookup e update.

### LOOKUP

livros(Cidadao) :
Recebe como argumento o ID da pessoa e retorna a lista de livros que essa pessoa requisitou.
```biblio: livros(1) ```e obterá os livros que a pessoa 1 requisitou.
Poderá fazê-lo da pessoa 1 a 5, sendo a pessoa 5 a única que não requisitou livros.

    emprestimos(Titulo:
Recebe como argumento o título do livro e retorna lista de pessoas que o requisitaram.
```biblio:emprestimos("The Fellowship of the Ring").``` ; ```biblio:emprestimos("Personal Account of the Everest Disaster").```

	requisitado(Codigo:
Recebe como argumento o código do livro e indica se já foi requisitado(true) ou não(false).
  
```biblio:requisitado(2001).```; ```biblio:requisitado(2003).```
Os códigos dos livros vão de 2001 a 2010 e os que ainda não foram requisitados foram o 2003,2009 e 2010.

	codigos(Titulo):
Recebe como argumento o título do livro e retorna lista de códigos desse livro.
```biblio:codigos("The Fellowship of the Ring").```; ```biblio:codigos("Personal Account of the Everest Disaster").```

	numRequisicoes(Cidadao):
Recebe como argumento o ID da pessoa, e retorna o número de livros requisitados.
```biblio:numRequisicoes(1).```
	Poderá fazê-lo da pessoa 1 a 5, sendo a pessoa 5 a única que não requisitou livros.
	
### UPDATE

	add_requisicao(IDp,IDl):
Recebe como argumentos, o id da pessoa e o id do livro e adiciona à base de dados.
Uma pessoa nova requisita um livro (pessoa 6 não estava na base de dados):
```biblio:add_requisicao(6,[2003]).``` 
Uma pessoa que já tinha requisitado um ou mais livros, requisitou mais um ou mais livros:
```biblio:add_requisicao(2,[2009,2010]).```

	remove_requisicao(IDp,IDl) :
Recebe como argumentos, o id da pessoa e o id do livro e retira da base de dados.
A pessoa 4 entregou 2 livros, mas tinha requisitado 3:
```biblio:remove_requisicao(4,[2008,2002]).```
A pessoa 2 entregou o seu único livro:
```biblio:remove_requisicao(2,[2004]).```
