Screenshot of a main screen x2
•	Action prompt - code snippet image, square
```ruby
# app/agents/inventory_agent.rb
class InventoryAgent < ActiveAgent::Base
  def search
    @items = Item.search(params[:query])
  end
end

# app/views/inventory_agent/search.text.erb
<%= render('inventory/search') %>
```
```yaml
# app/views/inventory_agent/search.yaml
name: "search_items"
description: "Search for items"
parameters:  
  type: object
  properties:
    query:
      type: string
      description: "Search query"
  required:
    - query
# Format: https://json-schema.org/understanding-json-schema      
```

•	Generation provider - code snippet image, square
```ruby
class InventoryAgent < ActiveAgent::Base
  generate_with :openai, model: 'gpt-4o-mini', temperature: 0.5

  def instructions
    @account = Account.find(params[:account_id])
  end
end
```

```ruby
# app/views/inventory_agent/instructions.text.erb
You are an inventory manager for <%= @account.name %>
```

•	Queued generation - code snippet image, square

```ruby
InventoryAgent.with(query: query).search.generate_later

InventoryAgent.with(query: query, prompt: "This is an inline prompt").prompt.generate_later
```

•	Callbacks - code snippet image, square
```ruby
class InventoryAgent < ActiveAgent::Base
  before_action :set_account
  after_generate :save_response
  generate_with :openai, model: 'gpt-4o-mini'

  def search
    @items = Item.search(params[:query])
  end

  private
  def set_account
    @account = Account.find(params[:account_id])
  end
  def save_response
    @message = Message.create(@response.message)
  end
end
```

•	Steaming - code snippet image, square
```ruby
class InventoryAgent < ActiveAgent::Base
  generate_with :openai, model: 'gpt-4o-mini', stream: :broadcast_results

  def search
    @items = Item.search(params[:query])
    prompt(stream: :broadcast_results)
  end

  private
  def broadcast_results
    proc do |chunk, _bytesize|
      @message.content = @message.content + chunk
      broadcast_append_to(
        "#{dom_id(chat)}_messages",
        partial: "messages/message",
        locals: { message: @message, scroll_to: true },
        target: "#{dom_id(chat)}_messages"
      )
    end
  end
end

InventoryAgent.with(prompt: prompt,stream: broadcast_results).prompt.generate_later
```
•	Solid agent — need some kind of square image 

•	Rails-native — square (code snippet? Or something else?)
```ruby
InventoryAgent.with(prompt: prompt,stream: broadcast_results).prompt
=> <
```
•	Lightweight — square 


•	Flexible & extensible — square


  
# Active Agent
```ruby
class ApplicationAgent < ActiveAgent::Base
  def generate
    # Default action prompt method
  end
end
```
## Action Prompt
```ruby
class InventoryAgent < ActiveAgent::Base
  def search
  end
end
```

By default the `ActiveAgent::Base` class will look for a method called `generate` and `search` in the class that inherits from it. This allows you to define actions that render Action Prompt objects as HTML, JSON schema with Action View.

## Prompting
```ruby
class InventoryAgent < ActiveAgent::Base
  def search
    prompt()
  end
end
```

## Generation Provider

## Parameterized

## Generation

## Generation Job

### Queued Generation

## Callbacks