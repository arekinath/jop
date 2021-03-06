package com.jopdesign.wcet.graphutils;

/**
 * Implementors provide integral IDs for objects of type T
 *
 * @param <T>
 */
public interface IDProvider<T> {
	public int getID(T t);
	public T fromID(int id); /* optional */
}
