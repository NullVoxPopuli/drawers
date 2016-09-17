# rails_module_unification
Ember's module unification brought to Rails.

## What is this about?

With large rails application, the default architecture can result in a resource's related files being very spread out through the overall project structure. For example, lets say you have 50 controllers, serializers, and operations. That's 3 different top level folders that spread out all the related objects. It makes sense do it this way, as it makes rails' autoloading programmatically easy.

This gem provides a way to re-structure your app so that like-objects are grouped together.

### The new structure


```
app/
├── channels/
├── data/
│   └── models/
│       ├── post.rb
│       ├── comment.rb
├── jobs/
├── mailers/
│   └── notification_mailer.rb
└── resources/
    ├── posts/
    │   ├── controller.rb
    │   ├── operation.rb
    │   ├── policy.rb
    │   └── serializer.rb
    └── comments/
        ├── controller.rb
        └── serializer.rb

```
