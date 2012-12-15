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

```
backend
frontend_A
frontend_B
client
```

## Installation

Add this line to your application's Gemfile:

    gem 'grandprix'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grandprix

## Usage

Just run
    
    topology -t topology_file elements_file 

Check out the doc/sample directory for sample
topology and elements files

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
