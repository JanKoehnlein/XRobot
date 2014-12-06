/*******************************************************************************
 * Copyright (c) 2014 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.xtext.xrobot.net

interface INetConfig {
	static val DISCOVERY_PORT = 3016
	static val DISCOVERY_PACKET_SIZE = 32
	
	static val SERVER_PORT = 4444
	
	static val SOCKET_TIMEOUT = 1000
	
	static val BUFFER_SIZE = 32768
	static val UPDATE_INTERVAL = 10
}