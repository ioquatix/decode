`bundle exec bake decode:rbs:generate ../../socketry/async/lib/kernel/sync.rb`

and 

`bundle exec bake decode:rbs:generate ../../socketry/async/lib/kernel/async.rb`

Work independently of each other, but togther:

`bundle exec bake decode:rbs:generate ../../socketry/async/lib/kernel`

It's missing the Async method.

I'm guessing this code which trys to find root declarations is wrong. TBH, I don't really understand why the agent wrote that code previously. Can you add some debugging puts to see what's going on?
