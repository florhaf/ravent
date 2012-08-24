package com.chaman.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.concurrent.ThreadFactory;

import com.google.appengine.api.ThreadManager;
import com.google.apphosting.api.ApiProxy;

public class MyThreadManager<T> {
	
	private static int CRT_NUMBER_OF_THREAD_RUNNING = 0;
	private static final int MAX_NB_OF_RUNNING_THREAD = 5;
	
	private Map<Thread, Long> threadPool;
	private List<T> result;
	
	public MyThreadManager(Runnable r) {
		
		result = new ArrayList<T>();
		threadPool = new HashMap<Thread, Long>(MAX_NB_OF_RUNNING_THREAD);
		
		ThreadFactory f = ThreadManager.currentRequestThreadFactory();
		
		for (int i = 0; i < MAX_NB_OF_RUNNING_THREAD; i++) {
			
			Thread thread = f.newThread(r);
			threadPool.put(thread, 0L);
		}
	}
	
	public List<T> Process(Queue<Long> queue) {
		
		do {
			
			if (CRT_NUMBER_OF_THREAD_RUNNING < MAX_NB_OF_RUNNING_THREAD) {
				
				Long id = queue.poll();
				
				if (id != null) {
					
					Thread t = this.getFirstAvailableThreadFromPool();
					
					if (t != null) {
						
						this.setIdForThread(t, id);
						
						t.start();
						
						CRT_NUMBER_OF_THREAD_RUNNING++;
					}
				}
			}
			
		} while ((!queue.isEmpty() && 											// stuff to process
				CRT_NUMBER_OF_THREAD_RUNNING > 0) ||								// stuff processing
				ApiProxy.getCurrentEnvironment().getRemainingMillis() > 20 * 1000);	// time remaining before time out
		
		this.killAllThread();
		
		return result;
	}
	
	public void AddToResultList(T model) {
		
		synchronized(this) {
		
			result.add(model);
		}
	}
	
	public void threadIsDone() {
		
		synchronized (this) {
		
			CRT_NUMBER_OF_THREAD_RUNNING--;
		}
	}
	
	public long getIdForThread(Thread t) {
		
		return threadPool.get(t);
	}
	
	private void setIdForThread(Thread t, Long id) {
		
		threadPool.put(t, id);
	}
	
	private Thread getFirstAvailableThreadFromPool() {
		
		for (Thread t : threadPool.keySet()) {
			
			if (!t.isAlive()) {
				
				return t;
			}
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
