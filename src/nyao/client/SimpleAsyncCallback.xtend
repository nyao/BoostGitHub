package nyao.client

import com.google.gwt.user.client.rpc.AsyncCallback
import com.google.gwt.core.client.GWT

class SimpleAsyncCallback<T> implements AsyncCallback<T> {
    
    def static <T> AsyncCallback<T> onCallback((T)=>void onSuccess) {
        val x = new SimpleAsyncCallback<T>()
        x.onSuccessDo(onSuccess)
        return x
    }
    
    (T)=>void onSuccess = []
    
    def void onSuccessDo((T)=>void onSuccess) {
        this.onSuccess = onSuccess
    }
    
    override onFailure(Throwable caught) {
        GWT::log("error", caught)
    }
    
    override onSuccess(T result) {
        this.onSuccess.apply(result)
    }
    
}