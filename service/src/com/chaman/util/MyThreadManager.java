package com.chaman.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.ThreadFactory;
import java.util.logging.Logger;

import com.chaman.model.Model;
import com.google.appengine.api.ThreadManager;
//import com.google.apphosting.api.ApiProxy;

public class MyThreadManager<K> {
	
	private static final Logger log = Logger.getLogger(MyThreadManager.class.getName());
	
	private static int CRT_NUMBER_OF_THREAD_RUNNING = 0;
	private static final int MAX_NB_OF_RUNNING_THREAD = 9;
	
	private Map<Thread, K> threadPool;
	private List<Model> result;
	
	ThreadFactory f;
	Runnable r;
	
	public MyThreadManager(Runnable r) {
		
		this.r = r;
		
		result = new ArrayList<Model>();
		threadPool = new HashMap<Thread, K>(MAX_NB_OF_RUNNING_THREAD);
		
		f = ThreadManager.currentRequestThreadFactory();
		
		for (int i = 0; i < MAX_NB_OF_RUNNING_THREAD; i++) {
			
			Thread thread = f.newThread(r);
			threadPool.put(thread, null);
		}
	}
	
	public List<Model> Process(Queue<K> queue) {
		
		do {
			
			if (CRT_NUMBER_OF_THREAD_RUNNING < MAX_NB_OF_RUNNING_THREAD) {
				
				K k = queue.poll();
				
				if (k != null) {
					
					Thread t =  this.getFirstAvailableThreadFromPool();
					
					if (t != null) {
						
						this.setIdForThread(t, k);
						
						try {

							t.start();						
						} catch (Exception ex) {
							
							log.severe(ex.toString());
						}
						
						
						CRT_NUMBER_OF_THREAD_RUNNING++;
					}
				}
			}
			
		} while ((queue.size() > 1 || 											// stuff to process
				CRT_NUMBER_OF_THREAD_RUNNING > 0));	// time remaining before time out
		
		//this.killAllThread();
		
		return result;
	}
	
	public void AddToResultList(Model model) {
		
		synchronized(this) {
		
			result.add(model);
		}
	}
	
	public void threadIsDone(Thread t) {
		
		synchronized (this) {
			
			threadPool.put(t, null);
		
			CRT_NUMBER_OF_THREAD_RUNNING--;
		}
	}
	
	public K getIdForThread(Thread t) {
		
		return threadPool.get(t);
	}
	
	private void setIdForThread(Thread t, K k) {
		
		threadPool.put(t, k);
	}
	
	private Thread getFirstAvailableThreadFromPool() {
		
		Thread oldt = null;
		
		for (Thread t : threadPool.keySet()) {
			
			K k = threadPool.get(t);
			
			if (k == null) {
				
				oldt = t;
				break;
			}
		}
		
		if (oldt != null) {
			
			threadPool.remove(oldt);
			
			Thread newt = f.newThread(r);
			
			threadPool.put(newt, null);
			
			return newt;
		}
		
		return null;
	}
	
	private void killAllThread() {
	
		CRT_NUMBER_OF_THREAD_RUNNING = 0;
		
		for (Thread t : threadPool.keySet()) {
		
			t.interrupt();
		}
	}
}
