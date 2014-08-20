package org.xtext.xrobot.dsl.interpreter;

import com.google.common.base.Objects;
import com.google.inject.Injector;
import com.google.inject.Provider;
import com.google.inject.Singleton;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.List;
import java.util.function.IntConsumer;
import java.util.stream.IntStream;
import javax.inject.Inject;
import org.eclipse.emf.common.util.BasicDiagnostic;
import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.util.StringInputStream;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.ExclusiveRange;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.xtext.mindstorms.xrobot.server.RemoteRobotProxy;
import org.xtext.mindstorms.xrobot.server.RemoteRobotServer;
import org.xtext.xrobot.dsl.XRobotDSLStandaloneSetup;
import org.xtext.xrobot.dsl.interpreter.XRobotInterpreter;
import org.xtext.xrobot.dsl.validation.XRobotDSLValidator;
import org.xtext.xrobot.dsl.xRobotDSL.Program;

@Singleton
@SuppressWarnings("all")
public class REPL {
  public static void main(final String[] args) {
    XRobotDSLStandaloneSetup _xRobotDSLStandaloneSetup = new XRobotDSLStandaloneSetup();
    final Injector injector = _xRobotDSLStandaloneSetup.createInjectorAndDoEMFRegistration();
    REPL _instance = injector.<REPL>getInstance(REPL.class);
    _instance.run();
  }
  
  @Inject
  private Provider<XtextResourceSet> resourceSetProvider;
  
  @Inject
  private RemoteRobotServer server;
  
  @Inject
  private XRobotDSLValidator validator;
  
  @Inject
  private XRobotInterpreter interpreter;
  
  private RemoteRobotProxy _currentRobot;
  
  private int indent = 0;
  
  public String run() {
    try {
      String _xblockexpression = null;
      {
        this.server.start();
        InputStreamReader _inputStreamReader = new InputStreamReader(System.in);
        final BufferedReader reader = new BufferedReader(_inputStreamReader);
        boolean continue_ = true;
        String lines = "";
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("XRobot Shell - enter \'$help\' for help");
        _builder.newLine();
        InputOutput.<String>println(_builder.toString());
        while (continue_) {
          try {
            this.prompt();
            String _readLine = reader.readLine();
            final String line = _readLine.trim();
            boolean _startsWith = line.startsWith("$");
            if (_startsWith) {
              boolean _processShellCommand = this.processShellCommand(line);
              continue_ = _processShellCommand;
            } else {
              for (int i = 0; (i < this.indent); i++) {
                String _lines = lines;
                lines = (_lines + "   ");
              }
              String _lines = lines;
              lines = (_lines + line);
              String _lines_1 = lines;
              lines = (_lines_1 + "\n");
              boolean _or = false;
              boolean _contains = line.contains("{");
              if (_contains) {
                _or = true;
              } else {
                boolean _contains_1 = line.contains("}");
                _or = _contains_1;
              }
              if (_or) {
                IntStream _chars = line.chars();
                final IntConsumer _function = new IntConsumer() {
                  public void accept(final int it) {
                    switch (it) {
                      case 123:
                        REPL.this.indent++;
                        break;
                      case 125:
                        REPL.this.indent--;
                        break;
                    }
                  }
                };
                _chars.forEach(_function);
              }
              if ((this.indent < 0)) {
                throw new Exception("Mismatched curly braces");
              }
              if ((this.indent == 0)) {
                StringConcatenation _builder_1 = new StringConcatenation();
                _builder_1.append("program MyProg main {");
                _builder_1.newLine();
                _builder_1.append("\t");
                _builder_1.append(lines, "\t");
                _builder_1.newLineIfNotEmpty();
                _builder_1.append("}");
                _builder_1.newLine();
                final String model = _builder_1.toString();
                InputOutput.<String>println(model);
                lines = "";
                final Program program = this.parse(model);
                boolean _notEquals = (!Objects.equal(program, null));
                if (_notEquals) {
                  final long startTime = System.currentTimeMillis();
                  RemoteRobotProxy _currentRobot = this.getCurrentRobot();
                  final Object result = this.interpreter.execute(program, _currentRobot);
                  long _currentTimeMillis = System.currentTimeMillis();
                  final long duration = (_currentTimeMillis - startTime);
                  boolean _notEquals_1 = (!Objects.equal(result, null));
                  if (_notEquals_1) {
                    InputOutput.<Object>println(result);
                  }
                  InputOutput.<String>println((("(" + Long.valueOf(duration)) + "ms)"));
                }
              }
            }
          } catch (final Throwable _t) {
            if (_t instanceof Exception) {
              final Exception exc = (Exception)_t;
              String _message = exc.getMessage();
              String _plus = ("Error: " + _message);
              System.err.println(_plus);
              this.indent = 0;
              lines = "";
            } else {
              throw Exceptions.sneakyThrow(_t);
            }
          }
        }
        InputOutput.<String>println("Exiting REPL...");
        RemoteRobotProxy _currentRobot = this.getCurrentRobot();
        if (_currentRobot!=null) {
          _currentRobot.stop();
        }
        this.server.shutdown();
        this.server.join();
        _xblockexpression = InputOutput.<String>println("...finished");
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public boolean processShellCommand(final String line) {
    String _substring = line.substring(1);
    final String[] commands = _substring.split("\\s");
    String _head = IterableExtensions.<String>head(((Iterable<String>)Conversions.doWrapArray(commands)));
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(_head, null)) {
        _matched=true;
      }
      if (!_matched) {
        if (Objects.equal(_head, "help")) {
          _matched=true;
        }
      }
      if (_matched) {
        StringConcatenation _builder = new StringConcatenation();
        _builder.append("$help          print this text");
        _builder.newLine();
        _builder.append("$robot <name>  switch current robot");
        _builder.newLine();
        _builder.append("$list          list connected robots");
        _builder.newLine();
        _builder.append("$exit|$quit    exit REPL");
        _builder.newLine();
        _builder.append("<expression>   execute Xbase expression on current robot \'it\'");
        _builder.newLine();
        _builder.append("$              re-execute previous expression");
        _builder.newLine();
        InputOutput.<String>println(_builder.toString());
      }
    }
    if (!_matched) {
      if (Objects.equal(_head, "robot")) {
        _matched=true;
        String _get = commands[1];
        RemoteRobotProxy _robot = this.server.getRobot(_get);
        this._currentRobot = _robot;
      }
    }
    if (!_matched) {
      if (Objects.equal(_head, "exit")) {
        _matched=true;
      }
      if (!_matched) {
        if (Objects.equal(_head, "quit")) {
          _matched=true;
        }
      }
      if (_matched) {
        return false;
      }
    }
    if (!_matched) {
      if (Objects.equal(_head, "list")) {
        _matched=true;
        Iterable<String> _robotNames = this.server.getRobotNames();
        String _join = IterableExtensions.join(_robotNames, ", ");
        String _plus = ("Connected robots: " + _join);
        InputOutput.<String>println(_plus);
      }
    }
    if (!_matched) {
      InputOutput.<String>println("Invalid command. Enter \'$\' for help");
    }
    return true;
  }
  
  private String prompt() {
    String _xifexpression = null;
    if ((this.indent > 0)) {
      InputOutput.<String>print((("<" + Integer.valueOf(this.indent)) + ">"));
      ExclusiveRange _doubleDotLessThan = new ExclusiveRange(0, this.indent, true);
      for (final Integer i : _doubleDotLessThan) {
        InputOutput.<String>print("  ");
      }
    } else {
      String _elvis = null;
      RemoteRobotProxy _currentRobot = this.getCurrentRobot();
      String _name = null;
      if (_currentRobot!=null) {
        _name=_currentRobot.getName();
      }
      if (_name != null) {
        _elvis = _name;
      } else {
        _elvis = "(unconnected)";
      }
      String _plus = (_elvis + " > ");
      _xifexpression = InputOutput.<String>print(_plus);
    }
    return _xifexpression;
  }
  
  private Program parse(final String model) {
    try {
      final XtextResourceSet resourceSet = this.resourceSetProvider.get();
      URI _createURI = URI.createURI("dummy.xrobot");
      final Resource resource = resourceSet.createResource(_createURI);
      StringInputStream _stringInputStream = new StringInputStream(model);
      resource.load(_stringInputStream, null);
      EList<Resource.Diagnostic> _errors = resource.getErrors();
      boolean _isEmpty = _errors.isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        EList<Resource.Diagnostic> _errors_1 = resource.getErrors();
        final Function1<Resource.Diagnostic, String> _function = new Function1<Resource.Diagnostic, String>() {
          public String apply(final Resource.Diagnostic it) {
            return it.getMessage();
          }
        };
        List<String> _map = ListExtensions.<Resource.Diagnostic, String>map(_errors_1, _function);
        String _join = IterableExtensions.join(_map, "\n");
        String _plus = ("Syntax Error:\n" + _join);
        throw new Exception(_plus);
      }
      EList<EObject> _contents = resource.getContents();
      EObject _head = IterableExtensions.<EObject>head(_contents);
      final Program program = ((Program) _head);
      final BasicDiagnostic diagnostic = new BasicDiagnostic();
      this.validator.validate(program, diagnostic, null);
      int _severity = diagnostic.getSeverity();
      boolean _equals = (_severity == Diagnostic.ERROR);
      if (_equals) {
        throw new Exception(("Error:\n" + diagnostic));
      }
      return program;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  private RemoteRobotProxy getCurrentRobot() {
    RemoteRobotProxy _elvis = null;
    if (this._currentRobot != null) {
      _elvis = this._currentRobot;
    } else {
      Iterable<String> _robotNames = this.server.getRobotNames();
      List<String> _sort = IterableExtensions.<String>sort(_robotNames);
      String _head = IterableExtensions.<String>head(_sort);
      RemoteRobotProxy _robot = this.server.getRobot(_head);
      _elvis = (this._currentRobot = _robot);
    }
    return _elvis;
  }
}
