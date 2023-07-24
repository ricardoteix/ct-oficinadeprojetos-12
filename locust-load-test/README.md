# Teste de Carga com Locust

É preciso ter o Python 3.9 ou superior instalado na máquina. 

## Preparando o ambiente

### Crie um ambiente virtual na pasta **locust-load-test**:

```D:\projeto\locust-load-test> python -m venv env```

### Ative o ambiente criado:

*Windows*

```D:\projeto\locust-load-test> env\Scripts\activate```

*Linux*

```~/projeto/locust-load-test> source env/bin/activate```

### Instale as dependências

É preciso instalar as dependências do Python para o Locust.

Execute ocomando seguinte.

```D:\projeto\locust-load-test> pip install -r requirements.txt```

## Inicie o locust

No arquivo ``locustfile.py`` altere o valor da variável **host** para o endereço do seu Media CMS.

Execute *locust* no terminal.

``D:\projeto\locust-load-test> locust``

Você verá um mensagem com o endereço para acessar, geralmente http://localhost:8089. Exemplo:

```
D:\projeto\locust-load-test>
[2023-07-24]DESKTOP/locust.main: Starting web interface at http://0.0.0.0:8089 (accepting connections from all network interfaces)
[2023-07-24] DESKTOP-DLCJA4J/INFO/locust.main: Starting Locust 2.15.1
```

## Inciando o teste

Ao acessar o Locust pelo navegador você deverá informar a quantidade máxima de usuários virtuais em *Number of users (peak concurrency)* e a quantidade de usuários virtuais criados por segundo, em *Spawn rate (users started/second)*.

O Host já deve vir preenchido com base no código.

Depois basta clicar em **Start swarmming** e navegar pelas abas para acompanhar o teste.

Quando desejar para clique no botão vermelho **Stop** no canto superior direito.
