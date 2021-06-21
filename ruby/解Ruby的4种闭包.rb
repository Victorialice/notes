原文链接：http://rubyer.me/blog/917/

理解Ruby的4种闭包：blocks, Procs, lambdas 和 Methods。

blocks, Procs, Methods, lambdas(也称闭包)是Ruby中最强大的一部分，用过你就会知道，同时也是最容易迷惑的。
这可能是因为Ruby处理闭包的方式有点怪。更甚的是，Ruby有4种处理闭包的方式, 第一次用，每种都不太顺手。

首先：blocks代码块
最常见、最简单、最富争议、最有Ruby风格的方式是blocks。写法如下：

array = [1, 2, 3, 4]
array.collect! do |n|
  n ** 2
end
puts array.inspect

# => [1, 4, 9, 16]
do…end构成一个block。然后把这个block通过collect!传给一个数组。就可以使用block中的n来迭代数组中每个元素。

collect!是Ruby库里的方法，下面我们来写一个自己的类似方法iterate!

class Array
  def iterate!
    self.each_with_index do |n, i|
      self[i] = yield(n)
    end
  end
end
array = [1, 2, 3, 4]
array.iterate! do |n|
  n ** 2
end
puts array.inspect
# => [1, 4, 9, 16]
首先，我们打开Array，并添加进iterate!方法。方法名以!结尾表示危险方法，引起注意。现在我们就可能像使用collect!一样使用iterate!

与属性不同，在方法中不需要指定block的名字，而是使用yield来调用。yield会执行block中的代码。同时，注意我们是怎么把n(each_with_index当前处理的数字)传给yield的。传给yield的参数即对应了block中的参数(||中的部分)。现在n就能被block调用并在yield调用中返回n**2。
整个调用如下：
1、一个整数组成的数组调用iterate!
2、当yield被调用时，把n(第一次为1，第二次为2，…)传给block
3、block对n进行n**2。因为是最后一行，自动作为结果返回。
4、yield得到block的结果，并把值重写到array里。
5、数据中每个对象执行相同操作。

以上仅仅是个开始，yield只是调用block的一种方式，还有一种叫Proc，看看。
class Array
  def iterate!(&code)
    self.each_with_index do |n, i|
      self[i] = code.call(n)
    end
  end
end

array = [1, 2, 3, 4]
array.iterate! do |n|
  n ** 2
end
puts array.inspect
# => [1, 4, 9, 16]
和上一段代码只有两个不同
1、为iterate!传递一个参数&code，&表示这个参数是block。
2、在iterate!中没有使用yield而是call。
结果相同，为什么还要这种不同的语法呢？让我们先来看一个到底什么是blocks吧？

def what_am_i(&block)
  block.class
end

puts what_am_i {}

# => Proc

block竟然是Proc！那Proc是什么?



Procs 过程

blocks很简单，但当我们需要处理很多blocks，多次使用一个blocks时，我们不得不重复代码。既然Ruby是完全面向对象的，我们就能把这些可复用的代码保存成object。这段可复用的代码就是Proc(procedure的简称)
block与Proc惟一的不同是：block是不能保存的Proc，一性的。

class Array
  def iterate!(code)
    self.each_with_index do |n, i|
      self[i] = code.call(n)
    end
  end
end

array_1 = [1, 2, 3, 4]
array_2 = [2, 3, 4, 5]

square = Proc.new do |n|
  n ** 2
end

array_1.iterate!(square)
array_2.iterate!(square)

puts array_1.inspect
puts array_2.inspect

# => [1, 4, 9, 16]
# => [4, 9, 16, 25]
注意：并没有在 iterate!的参数头部添加&，因为Proc只是一个普通类，不需要特殊处理。

上面的方式也是大多数语言处理闭包的方式。
而block是Ruby特有的方式。
另外Ruby不只使用blocks做闭包还有一个原因。比如有时我们需要传递多个闭包给一个方法，这时block马上力不从心了。但我们可以用Proc:
def callbacks(procs)
  procs[:starting].call

  puts "Still going"

  procs[:finishing].call
end

callbacks(:starting => Proc.new { puts "Starting" },
          :finishing => Proc.new { puts "Finishing" })

# => Starting
# => Still going
# => Finishing
所以，什么时候用blocks而不用Procs呢？我一般这样判断：
1、Block:方法把一个对象拆分成很多片段，并且你希望你的用户可以与这些片段做一些交互。
2、Block:希望自动运行多个语句，如数据库迁移(database migration)。
3、Proc:希望多次复用一段代码。
4、Proc:方法有一个或多个回调方法(callbacks)。

为什么block小写，而Proc大写
这只是我个人习惯。因为Proc是Ruby中的一个类似，而blocks并没有自己的类(本质上只是Procs)，只是一种语法规则。后面的lambda 小写也是如此。

Lambda 拉姆达表达式
上面的Procs与blocks用法很像其它语言中的匿名函数(即lambdas)。Ruby也支持lambdas.

class Array
  def iterate!(code)
    self.each_with_index do |n, i|
      self[i] = code.call(n)
    end
  end
end

array = [1, 2, 3, 4]

array.iterate!(lambda { |n| n ** 2 })

puts array.inspect

# => [1, 4, 9, 16]
lambdas看起来很像Procs，但它们有2个细微的区别。
1、lambdas检查参数的个数，Procs不会。
def args(code)
  one, two = 1, 2
  code.call(one, two)
end
args(Proc.new{|a, b, c| puts "Give me a #{a} and a #{b} and a #{c.class}"})

args(lambda{|a, b, c| puts "Give me a #{a} and a #{b} and a #{c.class}"})
# => Give me a 1 and a 2 and a NilClass
# *.rb:8: ArgumentError: wrong number of arguments (2 for 3) (ArgumentError)
可以看到，在Proc中，多余的参数被设为nil。但lambdas中，Ruby抛出了一个错误。
2、return不同。lambdas的return是返回值给方法，方法会继续执行。Proc的return会终止方法并返回得到的值。有点拗口，下面看例子。

def proc_return
  Proc.new { return "Proc.new"}.call
  return "proc_return method finished"
end

def lambda_return
  lambda { return "lambda" }.call
  return "lambda_return method finished"
end

puts proc_return
puts lambda_return
proc_return中，执行到Proc.new中的return时，直接返回”Proc.new”，不继续执行。
lambda_return中，执行到lambda中的return时，返回”lambda”，方法继续执行。

为什么会有这样的不同？
答案在于procedures和methods概念上的不同。
Ruby中的Procs是代码片段(code snippets)，不是方法。因此，Proc的return就是整个方法的return。
但lambdas就像是单独的methods(只不过是匿名的)，所以它要检查参数个数，且不会覆盖整个方法的返回。
因此，最好把lambdas当作另一种methods的写法，一种匿名的方式。

所以，什么时候用lambda而不是Proc呢？可以参考下面代码：

def generic_return(code)
  code.call
  return "generic_return method finished"
end

puts generic_return(Proc.new { return "Proc.new" })
puts generic_return(lambda { return "lambda" })

# => *.rb:6: unexpected return (LocalJumpError)
# => generic_return method finished
Ruby语法中一般参数(例子中为Proc)不能含有return。但使用了lambda后可以用return。
还可以参考：
def generic_return(code)
  one, two    = 1, 2
  three, four = code.call(one, two)
  return "Give me a #{three} and a #{four}"
end

puts generic_return(lambda { |x, y| return x + 2, y + 2 })

puts generic_return(Proc.new { |x, y| return x + 2, y + 2 })

puts generic_return(Proc.new { |x, y| x + 2; y + 2 })

puts generic_return(Proc.new { |x, y| [x + 2, y + 2] })

# => Give me a 3 and a 4
# => *.rb:9: unexpected return (LocalJumpError)
# => Give me a 4 and a
# => Give me a 3 and a 4

使用lambda，代码很自然。但如果用Proc，我们需要对Arrays进行赋值。

Method 对象
当你想把一个方法以闭包的形式传递给另一个方法，并且保持代码DRY。你可以使用Ruby的method方法。

class Array
  def iterate!(code)
    self.each_with_index do |n, i|
      self[i] = code.call(n)
    end
  end
end

def square(n)
  n ** 2
end

array = [1, 2, 3, 4]

array.iterate!(method(:square))

puts array.inspect

# => [1, 4, 9, 16]

例子中，我们先有了一个square方法。我们可以把它转换成一个Method对象并以参数形式传递给iterate!方法。但，这个新对象属于哪个类呢?

def square(n)
  n ** 2
end

puts method(:square).class

# => Method

如你所料，square不是Proc，而是Method。Method与lambda用法相同，因为它们的概念是一样的。不同的是Method是有名字的method，而lambda是匿名method.

总结
到此为止，我们已经了解了Ruby的4种闭包类型：blocks, Procs, lambdas 和 Methods。
blocks和Procs看起来像在代码中插入代码片段。而lambdas和Methods看起来像方法。
通过几个例子和比较，希望你能了解如何灵活运用闭包，游刃有余！