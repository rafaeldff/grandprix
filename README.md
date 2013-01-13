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


## How it works

### The Basics

The basic function of grandprix is to to reorder a list of elements according to
a separately specified happens-before relation, a _topology_. The rule is
simple: an element **A** will be before another element **B** in the output
whenever there is a requirement on the topology that **B** must come after
**A**. This requirement may be direct — **B** is in the `after` list for the
**A** node in the input topology file — or it may be indirect — **A**'s `after`
list contains an element that itself has **B** in its list, and so on. If you
know some graph theory you may have recognized the rule as a _topological sort_,
and indeed **grandprix** is not more than a little topsort engine.

The `doc/sample/simple` directory contains sample topology and input files, and
an example of grandprix's output.

Grandprix offers a few more conveniences, illustrated on the `doc/sample`
directories:

### Extra input data
Elements can contain extra data that will carry over to the output, such as
version or environment information. Just append an equals sign and the info you
want to each element. For instance if you want to append version numbers, the
elements input file could be something like this: 

```
frontend=1.0.0
client=2.0.3
backend=4.0.0
```

The output would be a permutation of the input lines according to the rules
given on the topology. This may be useful to integrate grandprix into your
scripting workflow.

Check out the `elements_with_extra_info` directory for example input and
outputs.

### Topology annotations
Adding extra data to the input elements is great for information that changes
with each run, but it would be tedious to have to always append information
about the elements that is more long-lasting. For this, grandprix offers a way
to annotate the elements on the topology file:

```
frontend:
  after: [backend, images]
  annotation: company-frontend-script 

images:
  annotation:              
    recipe: image-server
    script: install-images

backend:
  after: [db]
  annotation:    
    - This
    - And that
```

The above shows the types of annotations that can be added to each node: simple
strings, hashes, and arrays of items. These values will carry over to the
output for each `grandprix` run:

```
images=2.0.3={"recipe":"image-server","script":"install-images"}
backend=4.0.0=["This","And that"]
frontend=1.0.0=company-frontend-script
```

In the above outout it can be seen that annotations are output for each element
after a second equals sign. Strings are output straight through, arrays and
objects are converted to a JSON serialization.

Sample files are on the `doc/sample/annotated_topology` directory.

### Alongside Elements
Another common occurrence is the need to specify that some elements must always
be accompanied by others. For instance, still on the deploy use case, sometimes
we want to say that a certain service — say, a front-end server — must always be
deployed alongside anoter — it could a static assets server in this example. 

The relationship is specified as an `alongside` entry on a node's topology file:

```
frontend:
  after: [backend]             
  alongside: [assets, images]   # Frontend is always accompanied
                                # by assets and images

backend:
  alongside: [external_backend]

images:
  after: [client] #images that is an alongside dep of frontend
                  # can declare itself as after client
```

When an element that declares alongside elements is part of the input, the
alongside elements are output as well. They inherit their declaring node's order
restrictions, but they can declare their own order restrictions which are also
obeyed.

See the `doc/sample/alongside_elements` and `doc/sample/alongside_elements_2`
directories.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
