package nyao.util

import com.google.gwt.user.client.Timer

class XtendTimer extends Timer {
    
    def static timer(() => void f) {
        val timer = new XtendTimer
        timer.onRun(f)
        return timer
    }
    
    () => void run
    
    def onRun(() => void f) {
        run = f
    }

    override run() {
        this.run.apply()
    }
    
}