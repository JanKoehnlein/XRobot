package org.xtext.xrobot.dsl.ui.run

class Foo {
	def bar(int x) {}
	def foo() {
		new Bar().bar('', 1)
	}
}

class Bar {
	def bar(String x, int i) {}
}