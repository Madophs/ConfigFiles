#include <ace/Reactor.h>
#include <ace/SOCK_Acceptor.h>
#include <ace/Synch.h>
// This header contains peer() methods and Svc_Handler.cpp contains the declaration
#include <ace/Svc_Handler.h>

#define PORT_NO 2532
#define DATA_SIZE 256

typedef ACE_SOCK_Acceptor Acceptor;

class Mds_Accept_Handler;

//class Mds_Input_Handler : public ACE_Svc_Handler<ACE_SOCK_STREAM, ACE_NULL_SYNCH>{
class Mds_Input_Handler : public ACE_Event_handler {
	public:
		Mds_Input_Handler() {
			ACE_DEBUG((LM_DEBUG, "Mds Input Handler contructor\n"));
		}

		int handle_input(ACE_HANDLE) {
			// peer() method not found
	ACE_DEBUG((LM_DEBUG, "Hi there\n"));
			peer().recv_n(data, DATA_SIZE);
			ACE_DEBUG((LM_DEBUG, "Data = %s\n", data));
			return 0;	
		}
		ACE_HANDLE get_handle() const {
			return this->peer_i().get_handle();
		}

		ACE_SOCK_Stream & peer_i() const{
			return this->peer_;
		}
	private:
		ACE_SOCK_Stream peer_;
		char data [DATA_SIZE];
};

class Mds_Accept_Handler: public ACE_Event_Handler {
	public:
		Mds_Accept_Handler(ACE_Addr &addr) {
			this->open(addr);
		}

		int open(ACE_Addr &addr) {
			peer_acceptor.open(addr);
			return 0;
		}
		int handle_input(ACE_HANDLE handle) {
			Mds_Input_Handler *eh = new Mds_Input_Handler();
			if(this->peer_acceptor.accept(eh->peer(), 0, 0, 1) == -1) {
				ACE_DEBUG((LM_ERROR, "Error in connection\n"));
			}
			ACE_DEBUG((LM_DEBUG, "Connection established\n"));
			ACE_Reactor::instance()->register_handler(eh, ACE_Event_Handler::READ_MASK);
			return -1;
		}

		ACE_HANDLE get_handle(void) const {
			return this->peer_acceptor.get_handle();
		}		
	private:
		Acceptor peer_acceptor;
};

int main(int argc, char * argv[]) {
	ACE_INET_Addr addr(PORT_NO);
	Mds_Accept_Handler *eh = new Mds_Accept_Handler(addr);
	ACE_DEBUG((LM_DEBUG, "Hi there\n"));
	ACE_Reactor::instance()->register_handler(eh, ACE_Event_Handler::ACCEPT_MASK);
	while(true) {
		ACE_Reactor::instance()->handle_events();
	}
	return 0;
}
