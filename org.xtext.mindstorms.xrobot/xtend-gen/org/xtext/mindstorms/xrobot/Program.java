package org.xtext.mindstorms.xrobot;

import java.util.List;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.internal.c;
import org.xtext.mindstorms.xrobot.IProgram;
import org.xtext.mindstorms.xrobot.IRobot;
import org.xtext.mindstorms.xrobot.ISubProgram;

@SuppressWarnings("all")
public class Program implements IProgram {
  public static class GameOverSub implements ISubProgram {
    private Program program;
    
    public GameOverSub(final Program program) {
      this.program = program;
    }
    
    public String getName() {
      return "Game Over Detector";
    }
    
    public boolean checkCondition(final IRobot robot) {
      boolean _xblockexpression = false;
      {
        final float groundColor = robot.measureGroundColor();
        boolean _or = false;
        if ((groundColor > 0.2)) {
          _or = true;
        } else {
          boolean _escapePressed = robot.escapePressed();
          _or = _escapePressed;
        }
        _xblockexpression = _or;
      }
      return _xblockexpression;
    }
    
    public int getPriority() {
      return Integer.MAX_VALUE;
    }
    
    public void run(final IRobot robot) {
      this.program.isRunning = false;
    }
    
    public void stop(final IRobot robot) {
    }
  }
  
  private List<ISubProgram> subs = CollectionLiterals.<ISubProgram>newArrayList();
  
  private boolean isRunning = true;
  
  private ISubProgram activeSub;
  
  public Program() {
    Program.GameOverSub _gameOverSub = new Program.GameOverSub(this);
    this.addSubProgram(_gameOverSub);
  }
  
  public void run(final IRobot robot) {
    final Runnable _function = new Runnable() {
      public void run() {
        while (Program.this.isRunning) {
          {
            /* Program.this; */
            synchronized (Program.this) {
              {
                final Function1<ISubProgram, Boolean> _function = new Function1<ISubProgram, Boolean>() {
                  public Boolean apply(final ISubProgram it) {
                    return Boolean.valueOf(it.checkCondition(robot));
                  }
                };
                final ISubProgram highestPrioSub = IterableExtensions.<ISubProgram>findFirst(Program.this.subs, _function);
                boolean _notEquals = (!c.equal(Program.this.activeSub, highestPrioSub));
                if (_notEquals) {
                  boolean _notEquals_1 = (!c.equal(Program.this.activeSub, null));
                  if (_notEquals_1) {
                    String _name = Program.this.activeSub.getName();
                    String _plus = (_name + ".stop()");
                    InputOutput.<String>println(_plus);
                    if (Program.this.activeSub!=null) {
                      Program.this.activeSub.stop(robot);
                    }
                  }
                  Program.this.activeSub = highestPrioSub;
                }
              }
            }
            Thread.yield();
          }
        }
      }
    };
    final Thread conditionLoop = new Thread(_function);
    conditionLoop.start();
    while (this.isRunning) {
      {
        ISubProgram activeSubCopy = null;
        /* this; */
        synchronized (this) {
          activeSubCopy = this.activeSub;
        }
        boolean _notEquals = (!c.equal(this.activeSub, null));
        if (_notEquals) {
          String _name = this.activeSub.getName();
          String _plus = (_name + ".start()");
          InputOutput.<String>println(_plus);
          if (activeSubCopy!=null) {
            activeSubCopy.run(robot);
          }
        }
        Thread.yield();
      }
    }
  }
  
  public boolean addSubProgram(final ISubProgram sub) {
    boolean _xblockexpression = false;
    {
      for (int i = 0; (i < this.subs.size()); i++) {
        ISubProgram _get = this.subs.get(i);
        int _priority = _get.getPriority();
        int _priority_1 = sub.getPriority();
        boolean _lessThan = (_priority < _priority_1);
        if (_lessThan) {
          this.subs.add(i, sub);
          return true;
        }
      }
      _xblockexpression = this.subs.add(sub);
    }
    return _xblockexpression;
  }
}
