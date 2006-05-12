class Borges::Tutorial < Borges::GeeWeb

  def confirmCounter
    return ConfirmingCounter.new
  end

  def counter
    return Counter.new
  end

  def counterInspector
    return Inspector.on(self.componentNamed('counter'))
  end

  def empty
    return ''
  end

  def flowPage
    return %^Simple action methods, like <tt>#increment</tt>, simply modify the component's internal state, or, in a more complex application, interact with the domain model or database.  Action methods may also, however, make calls to other components.  Calling a component is much like a method or subroutine call: the new component takes control for as long as it wants, and is displayed in place of the old one.  Eventually, the new component may return control back to its caller
  #{empty}
  On the right is a counter that has been modified to create and call a simple dialog component as it goes below zero.  The decrement method now looks like this:
  <pre>
  <b>decrement</b>
  count = 0 ifTrue:
    do self.call: (Dialog message: "Going negative") end
  count := count - 1
  </pre>
  Clicking the "OK" button on the dialog will return control back to the counter
  #{informCounter}
  Components may also return a value as they return control to their caller.  This value is returned from the <tt>#call:</tt> message send.  For example, Dialog can be configured to present Yes and No buttons to the user, and return a true or false value.  This counter has the following decrement method:
  <pre>
  <b>decrement</b>
    |dialog|
    count = 0 ifTrue:
    do dialog := Dialog confirmation:
                "Are you sure you want to go negative?"
    (self.call: dialog)  ifFalse: do return self.endend
      
    count := count - 1
  </pre>
  #{confirmCounter}^
  end

  def incrementEditor
    return MethodEditor.class_selector(Counter, :increment)
  end

  def informCounter
    return InformingCounter.new
  end

  def page1
    return %^Welcome to the Seaside tutorial.  The purpose of this tutorial is to introduce and demonstrate some of Seaside's features in a dynamic, interactive way.  As you progress through the tutorial, you will get to use, inspect, and modify a set of prebuilt examples and tools.  Each example will appear in the right margin of this page, where you can interact with it at your leisure. explanatory text will appear on the left
  #{empty}
  The central class in the Seaside framework is Component.  Each part of a Seaside user interface is controlled by a separate component subclass.  Some components may be very small, modelling a navigation control or specialized form input.  Larger components might model an entire page, and would embed many smaller subcomponents within themselves.  Seaside applications are built through the interactions of many such large components
  <p>
  Embedded to the right is the "hello world" of components: a simple counter.  Over the next few pages of this tutorial we will be examining this component class in detail
  #{counter}
  ^
  end

  def page2
    return %^The first responsibility of a component class is to model user interface state.  This state usually corresponds to what's being displayed on the screen: for example, the component may be keeping track of which record is being displayed, the current values in a form, or which nodes of a navigation tree are expanded
  #{empty}
  The component on the right, implemented by the Counter class, has a single piece of state: the value of the numeric counter
  In its class definition, it defines a single instance variable, <tt>count</tt>, to maintain this:
  <pre>
  Component subclass: #Counter
    instanceVariableNames: 'count'
    classVariableNames: ''
    poolDictionaries: ''
    category: 'Seaside/Examples-Tutorial'
  </pre>
  #{counter}
  
  You can see here an inspector on the embedded counter, showing its <tt>count</tt> instance variable (<tt>continuation</tt> and <tt>delegate</tt> are defined in the Component superclass, we'll ignore them for now).  You'll notice that as you use the ++ and -- links, <tt>count</tt> tracks the changes
  #{counterInspector}
  ^
  end

  def page3
    return %^The second responsibility of a component is to handle user interface behavior.  This usually means having a method for each link or submit button it displays.  The Counter class has two such methods: <tt>#increment</tt>, which maps to the ++ link, and <tt>#decrement</tt>, which maps to the -- link.  Their implementations are very simple:
  <pre>
  <b>increment</b>
    count := count + 1
  
  <b>decrement</b>
    count := count - 1
  </pre>
  #{counter}
  Methods that are directly mapped to links or buttons are sometimes known as <i>action</i> methods
  <p>
  You can use this editor to modify the <tt>#increment</tt> action method.  For example, you can try changing it to
  <pre>
  <b>increment</b>
    count := count + 2
  </pre>
  Test your changes with the counter above
  #{incrementEditor}
  ^
  end

  def page4
    return %^The final responsibility of a component is to handle presentation.  Each component must implement a <tt>#renderContentOn:</tt> method that describes how it is displayed.  The single parameter to this message is an HtmlRenderer object, which implements many methods for conveniently building html
    
  <b>... more to come ...</b>
  ^
  end

end
