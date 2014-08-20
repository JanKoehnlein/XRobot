package org.xtext.xrobot.dsl.interpreter;

import com.google.inject.Inject;
import java.io.InputStream;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.xtext.xrobot.dsl.xRobotDSL.Program;

@SuppressWarnings("all")
public class ParseHelper {
  @Inject
  private XtextResourceSet resourceSet;
  
  public Program parse(final InputStream in) {
    try {
      URI _createURI = URI.createURI("dummy.xrobot");
      final Resource resource = this.resourceSet.createResource(_createURI);
      resource.load(in, null);
      EList<EObject> _contents = resource.getContents();
      EObject _head = IterableExtensions.<EObject>head(_contents);
      return ((Program) _head);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
