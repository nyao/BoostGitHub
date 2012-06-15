package nyao.util

import com.google.gwt.user.client.rpc.AsyncCallback

class ConfigurableAsyncCallback<T> implements AsyncCallback<T> {
    
    def static <T> AsyncCallback<T> onSuccess((T)=>void onSuccess) {
        val x = new ConfigurableAsyncCallback<T>()
        x.onSuccessDo(onSuccess)
        return x
    }
    def static <T> AsyncCallback<T> callback((ConfigurableAsyncCallback<T>)=>void init) {
        val x = new ConfigurableAsyncCallback<T>()
        init.apply(x)
        return x
    } 
    
    (Throwable)=>void onFailure
    (T)=>void onSuccess
    
    new() {
        onSuccess = []
        onFailure = []
    }
    
    def void onSuccessDo((T)=>void onSuccess) {
        this.onSuccess = onSuccess
    }
    
    def void onFailureDo((Throwable)=>void onFailure) {
        this.onFailure = onFailure
    }

    override onFailure(Throwable caught) {
        this.onFailure.apply(caught)
    }
    
    override onSuccess(T result) {
        this.onSuccess.apply(result)
    }
    
}