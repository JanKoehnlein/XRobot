package org.lejos.ev3.ldt.util;

import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.util.HashMap;
import java.util.Map;

public class Discover {

	private static final int DISCOVERY_PORT = 3016;
	
	/**
	 * Search for available EV3s and populate table with results.
	 * @throws Exception 
	 */
	public static BrickInfo[] discover() throws Exception {	
		DatagramSocket socket = null;
		
		try {
			Map<String,BrickInfo> ev3s = new HashMap<String,BrickInfo>();
			socket = new DatagramSocket(DISCOVERY_PORT);
			socket.setSoTimeout(2000);
	        DatagramPacket packet = new DatagramPacket (new byte[100], 100);
	
	        long start = System.currentTimeMillis();
	        
	        while ((System.currentTimeMillis() - start) < 3000) {
	            socket.receive (packet);
	            String message = new String(packet.getData(), "UTF-8");
	            String ip = packet.getAddress().getHostAddress();
	            ev3s.put(ip, new BrickInfo(message.trim(),ip,"EV3"));
	        }
	            
	        BrickInfo[] devices = new BrickInfo[ev3s.size()];
	        int i = 0;
	        for(String ev3: ev3s.keySet()) {
	        	BrickInfo info = ev3s.get(ev3);
	        	devices[i++] = info;
	        }
	        
	        return devices;
		} catch (Exception e) {
			throw new Exception("No EV3 Found: " + e);
		} finally {
	        if (socket != null) socket.close();
		}
	}
}
