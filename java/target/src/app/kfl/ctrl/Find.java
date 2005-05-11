/*
 * Find.java
 *
 * Created on 01. Februar 2002, 14:25
 */

/**
 *
 * @author  Standard
 */
import BBSys;
import Msg;

public class Find extends javax.swing.JFrame {

	private Msg m;
	private boolean exit = false;

	/** Creates new form Find */
	public Find(Msg m) {
		this.m = m;
		initComponents();
		doit();
	}

	private void doit() {
	
		txtLog.setText("");
		new Thread() {
			public void run() {
				for (int i=0; i<8; ++i) {
					final int val = m.exchg(i, BBSys.CMD_STATUS, 0);
					if (val<0) {
						m.clear();
					}
					final int idx = i;
					Runnable r = new Runnable() {
						public void run() {
							txtLog.append("Address "+idx+" ... ");
							if (val<0) {
									m.clear();
									txtLog.append("timeout\n");
							} else {
									txtLog.append("found\n");
							}
  						}
					};
					SwingUtilities.invokeLater(r);
				}
			}
		}.start();
	}

	/** This method is called from within the constructor to
	 * initialize the form.
	 * WARNING: Do NOT modify this code. The content of this method is
	 * always regenerated by the Form Editor.
	 */
	private void initComponents() {//GEN-BEGIN:initComponents
		jScrollPane1 = new javax.swing.JScrollPane();
		txtLog = new javax.swing.JTextArea();
		jButton1 = new javax.swing.JButton();
		
		setTitle("Find Stations");
		addWindowListener(new java.awt.event.WindowAdapter() {
			public void windowClosing(java.awt.event.WindowEvent evt) {
				exitForm(evt);
			}
		});
		
		jScrollPane1.setViewportView(txtLog);
		
		getContentPane().add(jScrollPane1, java.awt.BorderLayout.CENTER);
		
		jButton1.setText("Refresh");
		jButton1.addActionListener(new java.awt.event.ActionListener() {
			public void actionPerformed(java.awt.event.ActionEvent evt) {
				jButton1ActionPerformed(evt);
			}
		});
		
		getContentPane().add(jButton1, java.awt.BorderLayout.SOUTH);
		
		pack();
		java.awt.Dimension screenSize = java.awt.Toolkit.getDefaultToolkit().getScreenSize();
		setSize(new java.awt.Dimension(300, 200));
		setLocation((screenSize.width-300)/2,(screenSize.height-200)/2);
	}//GEN-END:initComponents

	private void jButton1ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jButton1ActionPerformed
		// Add your handling code here:
		doit();
	}//GEN-LAST:event_jButton1ActionPerformed

	/** Exit the Application */
	private void exitForm(java.awt.event.WindowEvent evt) {//GEN-FIRST:event_exitForm
		if (exit) {
			System.exit(0);
		} else {
			dispose();
		}
	}//GEN-LAST:event_exitForm

	/**
	* @param args the command line arguments
	*/
	public static void main(String args[]) {
		Msg m = new Msg();
		Find f = new Find(m);
		f.exit = true;
		f.show();
	}


	// Variables declaration - do not modify//GEN-BEGIN:variables
	private javax.swing.JScrollPane jScrollPane1;
	private javax.swing.JTextArea txtLog;
	private javax.swing.JButton jButton1;
	// End of variables declaration//GEN-END:variables

}
