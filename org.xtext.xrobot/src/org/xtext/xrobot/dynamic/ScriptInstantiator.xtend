package org.xtext.xrobot.dynamic

import java.io.ByteArrayOutputStream
import java.net.URL
import lejos.hardware.BrickFinder
import org.xtext.xrobot.Robot

class ScriptInstantiator {
	
	static class DynamicClassLoader extends ClassLoader {
		
		val cache = <String, Class<?>>newHashMap
		
		new(ClassLoader parent) {
			super(parent)
		}
		
		protected def add(String className, byte[] classData) {
			if(cache.containsKey(className)) 
				throw new RuntimeException('Class ' + className + ' already loaded')
        	cache.put(className, defineClass(className, classData, 0, classData.length))
		}
		
		override loadClass(String className) throws ClassNotFoundException {
			val class = cache.get(className)
			if(class != null)
				return class
            else
            	parent.loadClass(className)
		}
	}
	
	static val PATH = 'file:///home/lejos/programs/'
	
	ScriptInstantiator.DynamicClassLoader dynamicClassLoader = new ScriptInstantiator.DynamicClassLoader(ScriptInstantiator.classLoader)
	
	def IScript getScript(String className, byte[] classData) {
		dynamicClassLoader.add(className, classData)
		val clazz = dynamicClassLoader.loadClass(className)
		clazz.newInstance as IScript
	}
	
	def IScript getScript(String className) {
		dynamicClassLoader.add(className, readClassFile(className))
		val clazz = dynamicClassLoader.loadClass(className)
		clazz.newInstance as IScript
	}
	
	private static def readClassFile(String name) {
		val url = new URL(PATH + name.split('\\.').last + '.class')
		val input = url.openStream
		val buffer = new ByteArrayOutputStream()
        var data = input.read
        while (data != -1) {
            buffer.write(data)
            data = input.read()
        }
        input.close
        buffer.toByteArray
	}
	
	def static void main(String[] args) {
		new ScriptInstantiator().getScript('org.xtext.xrobot.examples.SampleScript').run(new Robot(BrickFinder.getLocal))
	}
}