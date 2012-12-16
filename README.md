# Grandprix

Grandprix is a small project with the sole function of imposing an ordering for
a happens-before relation. It was created to help with deploy orchestration, to
sort out which system should be upgraded before another, based on their
dependency relationship. For instance, say we have four systems: a backend
server, two frontend servers and a client. And we want to deploy new versions of
every system.

```                
                    
                        ----------------
               ---------|  frontend_A  |<--------
               v        ----------------        |
    -------------                              ------------  
    |  backend  |                              |  client  | 
    -------------                              ------------ 
               ^        ----------------        |
               ---------|  frontend_B  |<--------
                        ----------------
```

 You give grandprix a description of the ordering dependencies and a list of
 elements:

```
client:
  after: [frontend_A, frontend_B]

frontend_A:
  after: [backend]

frontend_B:
  after: [backend]
```

```
backend
client
frontend_A
frontend_B
```

And grandprix will output a correct ordering:

```yaml
backend
frontend_A
frontend_B
client
```

We call the description of the dependencies a _topology_.

## Using from the command line

### Instalation
The project is packaged as a rubygem, just make sure you have Ruby 1.9 installed
and run:

    $ gem install grandprix

### Usage
An executable called `grandprix` will be installed, and can be called like this:

    $ grandprix -t topology_file elements_file

The elements file argument can be omitted and grandprix will read them from
the standard in.

The `doc/sample/simple` directory has sample topology and elements files.


## Using as a library

### Instalation
Add this line to your application's Gemfile:

    gem 'grandprix'

And then execute:

    $ bundle

### Usage

The programatic API is very similar to the command line tool. Just call the
`run!` instance method on the `Grandprix::Runner` class, passing in a hash
representing the topology and an array of elements.

The `doc/sample/as_a_library` directory has an example ruby script calling
grandprix programatically.


## More 

Grandprix offers a few more conveniences, illustrated on the `doc/sample`
directories:

* Elements can contain extra data that will carry over to the output, such as
  version numbers. Just append an equals sign and the info you want to each
  element. Check out the `elements_with_extra_info` directory.
* The topology itself can define information that will propagate to the
  output, in the form of an `annotation` attribute. See the `annotated_topology`
  directory.
* Besides declaring that an element needs to come after others, grandprix also
  allows for an element to specify that it must always be accompanied by
  another, via the `alongside` attribute. This will extend the provided elements
  input. See the `alongside_elements` and `alongside_elements_2` directories.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
