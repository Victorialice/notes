# scope 原理浅析
## scope(name,scope_options={}) public
## 添加一个用于检索和查询对象的类方法
## 可以这样用
class Shirt < ActiveRecord::Base
  scope :red, where(:color => 'red')
  scope :end_date, ->(date) { where(:end_date => date)}
  scope :dry_clean_only, joins(washing_instructions).where('washing_instructions.dry_clean_only = ?', true)
end
上面的调用scope定义了类方法Shirt.red和Shirt.dry_clean_only。Shirt.red实际上代表查询Shirt.where(:color => 'red')
请注意，这只是用于定义实际类方法的 语法糖

实现的作用和类方法一样，但是类方法是在载入类的时候就会一起加载，而scope定义的方法是在方法调用时才会加载

class Shirt < ActiveRecord::Base
  def self.red
    where(color: 'red')
  end
end
不过需要注意的是，scope方法即使在什么也没查到的情况下依然会返回Relation对象，也就是说 scope 方法可以进行链式调用而不担心会抛出nil:NilClass 异常。

class Article < ActiveRecord::Base
  scope :published, -> {where(published: true)}
  scope :featured, -> {where(featured: true)}

  def self.latest_article
    order('published_at desc').first
  end

  def self.titles
    pluck(:title)
  end
end

我们可以这样调用方法：
Article.published.featured.latest_article
Article.featured.titles

下面看一下具体的实现源码:

def scope(name, body, &block)
  unless body.respond_to?(:call)
    raise ArgumentError, 'The scope body needs to be callable.'
  end

  if dangerous_class_method?(name)
    raise ArgumentError, "You tried to define a scope named \"#{name}\""
  end

  extension = Module.new(&block) if block
  singleton_class.send(:define_method, name) do |*args|
    scope = all.scoping { body.call(*args) }
    scope = scope.extending(extension) if extension
    scope || all
  end
end
