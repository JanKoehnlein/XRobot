package org.xtext.mindstorms.xrobot.util;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.Map;
import lejos.hardware.Audio;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.internal.c;

@SuppressWarnings("all")
public class SoundUtil {
  private Map<String, byte[]> samples = CollectionLiterals.<String, byte[]>newHashMap();
  
  public int playSample(final Audio audio, final String fileName, final int volume) {
    int _xblockexpression = (int) 0;
    {
      final byte[] sample = this.getSample(fileName);
      int _length = sample.length;
      _xblockexpression = audio.playSample(sample, 0, _length, 8000, volume);
    }
    return _xblockexpression;
  }
  
  protected byte[] getSample(final String fileName) {
    byte[] _xblockexpression = null;
    {
      byte[] sample = this.samples.get(fileName);
      boolean _equals = c.equal(sample, null);
      if (_equals) {
        byte[] _loadSample = this.loadSample(fileName);
        sample = _loadSample;
        this.samples.put(fileName, sample);
      }
      _xblockexpression = sample;
    }
    return _xblockexpression;
  }
  
  protected byte[] loadSample(final String fileName) {
    try {
      InputStream in = null;
      ByteArrayOutputStream out = null;
      try {
        Class<? extends SoundUtil> _class = this.getClass();
        ClassLoader _classLoader = _class.getClassLoader();
        InputStream _resourceAsStream = _classLoader.getResourceAsStream(fileName);
        in = _resourceAsStream;
        ByteArrayOutputStream _byteArrayOutputStream = new ByteArrayOutputStream();
        out = _byteArrayOutputStream;
        byte[] buffer = new byte[2048];
        int size = 0;
        int _read = in.read(buffer);
        int _size = size = _read;
        boolean _greaterThan = (_size > 0);
        boolean _while = _greaterThan;
        while (_while) {
          out.write(buffer, 0, size);
          int _read_1 = in.read(buffer);
          int _size_1 = size = _read_1;
          boolean _greaterThan_1 = (_size_1 > 0);
          _while = _greaterThan_1;
        }
        out.flush();
        return out.toByteArray();
      } finally {
        if (in!=null) {
          in.close();
        }
        if (out!=null) {
          out.close();
        }
      }
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
}
