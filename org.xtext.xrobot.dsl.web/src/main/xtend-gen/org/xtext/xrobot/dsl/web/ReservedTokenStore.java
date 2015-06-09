/**
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.xtext.xrobot.dsl.web;

import com.google.common.base.Objects;
import com.google.common.collect.HashMultimap;
import com.google.common.collect.LinkedHashMultimap;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;
import org.eclipse.xtend.lib.annotations.Data;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Pure;
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder;

@SuppressWarnings("all")
public class ReservedTokenStore {
  @Data
  public static class Entry {
    private final long timestamp;
    
    private final String token;
    
    private final String address;
    
    private final String uri;
    
    private final String source;
    
    public Entry(final long timestamp, final String token, final String address, final String uri, final String source) {
      super();
      this.timestamp = timestamp;
      this.token = token;
      this.address = address;
      this.uri = uri;
      this.source = source;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + (int) (this.timestamp ^ (this.timestamp >>> 32));
      result = prime * result + ((this.token== null) ? 0 : this.token.hashCode());
      result = prime * result + ((this.address== null) ? 0 : this.address.hashCode());
      result = prime * result + ((this.uri== null) ? 0 : this.uri.hashCode());
      result = prime * result + ((this.source== null) ? 0 : this.source.hashCode());
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      ReservedTokenStore.Entry other = (ReservedTokenStore.Entry) obj;
      if (other.timestamp != this.timestamp)
        return false;
      if (this.token == null) {
        if (other.token != null)
          return false;
      } else if (!this.token.equals(other.token))
        return false;
      if (this.address == null) {
        if (other.address != null)
          return false;
      } else if (!this.address.equals(other.address))
        return false;
      if (this.uri == null) {
        if (other.uri != null)
          return false;
      } else if (!this.uri.equals(other.uri))
        return false;
      if (this.source == null) {
        if (other.source != null)
          return false;
      } else if (!this.source.equals(other.source))
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("timestamp", this.timestamp);
      b.add("token", this.token);
      b.add("address", this.address);
      b.add("uri", this.uri);
      b.add("source", this.source);
      return b.toString();
    }
    
    @Pure
    public long getTimestamp() {
      return this.timestamp;
    }
    
    @Pure
    public String getToken() {
      return this.token;
    }
    
    @Pure
    public String getAddress() {
      return this.address;
    }
    
    @Pure
    public String getUri() {
      return this.uri;
    }
    
    @Pure
    public String getSource() {
      return this.source;
    }
  }
  
  @Data
  public static class ExecutorResult {
    private final String output;
    
    public ExecutorResult(final String output) {
      super();
      this.output = output;
    }
    
    @Override
    @Pure
    public int hashCode() {
      final int prime = 31;
      int result = 1;
      result = prime * result + ((this.output== null) ? 0 : this.output.hashCode());
      return result;
    }
    
    @Override
    @Pure
    public boolean equals(final Object obj) {
      if (this == obj)
        return true;
      if (obj == null)
        return false;
      if (getClass() != obj.getClass())
        return false;
      ReservedTokenStore.ExecutorResult other = (ReservedTokenStore.ExecutorResult) obj;
      if (this.output == null) {
        if (other.output != null)
          return false;
      } else if (!this.output.equals(other.output))
        return false;
      return true;
    }
    
    @Override
    @Pure
    public String toString() {
      ToStringBuilder b = new ToStringBuilder(this);
      b.add("output", this.output);
      return b.toString();
    }
    
    @Pure
    public String getOutput() {
      return this.output;
    }
  }
  
  public final static long MAX_AGE = ((1000l * 60) * 10);
  
  public final static int MAX_SCRIPT_SIZE = 65536;
  
  public final static int MAX_SCRIPTS_PER_ADDRESS = 50;
  
  private final HashMap<String, ReservedTokenStore.Entry> token2entry = CollectionLiterals.<String, ReservedTokenStore.Entry>newHashMap();
  
  private final HashMultimap<String, ReservedTokenStore.Entry> address2entry = HashMultimap.<String, ReservedTokenStore.Entry>create();
  
  private final LinkedHashMultimap<Long, ReservedTokenStore.Entry> time2entry = LinkedHashMultimap.<Long, ReservedTokenStore.Entry>create();
  
  public ReservedTokenStore.ExecutorResult add(final ReservedTokenStore.Entry entry, final String address) {
    try {
      int _length = entry.source.length();
      boolean _greaterThan = (_length > ReservedTokenStore.MAX_SCRIPT_SIZE);
      if (_greaterThan) {
        Thread.sleep(50);
        return new ReservedTokenStore.ExecutorResult("Script limit of 64k exceeded");
      }
      Set<ReservedTokenStore.Entry> _get = this.address2entry.get(address);
      int _size = _get.size();
      boolean _greaterThan_1 = (_size > ReservedTokenStore.MAX_SCRIPTS_PER_ADDRESS);
      if (_greaterThan_1) {
        Thread.sleep(50);
        return new ReservedTokenStore.ExecutorResult("Too many pending entries from the same address");
      }
      final String token = entry.token.toUpperCase();
      final ReservedTokenStore.Entry existingEntry = this.token2entry.get(token);
      boolean _notEquals = (!Objects.equal(existingEntry, null));
      if (_notEquals) {
        Thread.sleep(50);
        return new ReservedTokenStore.ExecutorResult("Token already reserved");
      }
      boolean _startsWith = entry.uri.startsWith("src/");
      if (_startsWith) {
        final String fileName = entry.uri.substring(4);
        boolean _and = false;
        boolean _contains = fileName.contains("/");
        boolean _not = (!_contains);
        if (!_not) {
          _and = false;
        } else {
          boolean _endsWith = fileName.endsWith(".xrobot");
          _and = _endsWith;
        }
        if (_and) {
          final long timestamp = System.currentTimeMillis();
          final ReservedTokenStore.Entry newEntry = new ReservedTokenStore.Entry(timestamp, token, address, fileName, entry.source);
          this.token2entry.put(token, newEntry);
          this.address2entry.put(address, newEntry);
          this.time2entry.put(Long.valueOf(timestamp), newEntry);
          this.collectGarbage(ReservedTokenStore.MAX_AGE);
          return new ReservedTokenStore.ExecutorResult("Token successfully reserved");
        }
      }
      Thread.sleep(50);
      return new ReservedTokenStore.ExecutorResult("Invalid URI");
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public ReservedTokenStore.Entry get(final String token) {
    String _upperCase = token.toUpperCase();
    return this.token2entry.get(_upperCase);
  }
  
  protected void collectGarbage(final long maxAge) {
    final long now = System.currentTimeMillis();
    Set<Long> _keySet = this.time2entry.keySet();
    ArrayList<Long> _arrayList = new ArrayList<Long>(_keySet);
    for (final Long timeStamp : _arrayList) {
      if ((((timeStamp).longValue() + maxAge) < now)) {
        Set<ReservedTokenStore.Entry> _get = this.time2entry.get(timeStamp);
        ArrayList<ReservedTokenStore.Entry> _arrayList_1 = new ArrayList<ReservedTokenStore.Entry>(_get);
        for (final ReservedTokenStore.Entry entry : _arrayList_1) {
          {
            this.token2entry.remove(entry.token);
            this.address2entry.remove(entry.address, entry);
          }
        }
        this.time2entry.removeAll(timeStamp);
      } else {
        return;
      }
    }
  }
}
