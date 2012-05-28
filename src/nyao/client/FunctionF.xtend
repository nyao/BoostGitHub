package nyao.client

import com.google.gwt.query.client.Function
import com.google.gwt.user.client.Event

class FunctionF extends Function {
	(Event)=>boolean onSuccess = []
	
	def static Function func((Event)=>boolean onSuccess) {
		val x = new FunctionF()
		x.f(onSuccess)
		return x
	}
	
	def void f((Event)=>boolean onSuccess) {
		this.onSuccess = onSuccess
	}
	
	override f(Event result) {
		this.onSuccess.apply(result)
	}
}
