
What we’ll learn:

  - configuration management    
 -    Ansible     
 -   What is Ansible?   
 - Creating VMs for demo      
 -  Installation      
 -  Ansible Ad hoc   commands      
 -  Ansible playbook       
 - Ansible Inventory | host file  
 - Configuring Ansible Host/cfg files     
 -   Writing a playbook      
 -   Running a playbook    
 -    Using custom inventory files       
 - Shutting  down VMs demo

   ---

### **Configuration Management**
The purpose of configuration management is to maintain systems in a desired state. It aims to eliminate configuration drift as much as possible. 
Configuration drift occurs when ad-hoc configuration changes and updates result in a mismatched development, test, and deployment environments. This can result in issues at deployment, security vulnerabilities, and risks when developing applications and services that need to meet strict regulatory compliance standards. 
Configuration management makes it possible to scale infrastructure without worrying about increasing staff or workload. It ensures consistency across all infrastructure, improves automation and mitigates human error.


### **Ansible**
Ansible is a very powerful and popular configuration management tool. Here are some quick facts that will interest you about Ansible:

 - The name “ansible” originally refers to a category of fictional technology capable of  faster-than-light communication. It can send and receive messages to and from a corresponding device over any distance or obstacle whatsoever with no delay.
 - Its name is used in sci-fi movies (e.g Enders Game)and novels
   (Ursula).
 - In the Enders Game, the story depends on the ansible to centrally
   control a huge, complex fleet of distant ships. This was what
   inspired Ansible automation software founders to choose the term as
   the name for their product.
 - Developed by Michael DeHaan, the creator of Cobbler and Func.

> Ansible is an ***agentless*** ***push-based*** configuration tool that
> functions by connecting via SSH to its managed nodes. It doesn’t need
> a special agent on the node and operates by pushing modules to the
> clients. The modules are then executed locally on the node, and the
> output is pushed back to the controller or host.

***Drift*** is the process of making changes on a host that makes it differ from the synced version.

## **Nodes for Demo:**

 - Spin-up 3 Ubuntu Linux VMs on portal.azure.com
 - Make user=*agent*, password=*password@101*.
 - Copy out the IP addresses of all 3 VMs

Ssh into any one that would serve as our control node, and proceed as follows.

## **Ansible Installation :**

 **Step 1**: Perform an update to the packages
 

       sudo apt update

  **Step 2**: Install the software-properties-common package
 

     sudo apt install software-properties-common

 **Step 3**: Add ansible personal package archive
 
    sudo apt-add-repository ppa:ansible/ansible

 **Step 4:** Install ansible

    sudo apt update  

    sudo apt install ansible

To test your installation, do:

    Ansible -v

## **Ansible Ad-hoc Commands:**

This is one of the simplest ways Ansible can be used to issue some commands on a server or a bunch of servers. Ad-hoc commands are not version controlled but represent a fast way to interact with the desired servers.

    Ansible -m ping localhost 

-*m* ==> module
*Ping* ==> module name
*Localhost* ==> target node

    Ansible -m copy -a “src=./file1.txt dest=~/file.txt” localhost 

To see if some changes would be implemented, do a dry run. Add ***‘--check’*** to the command. To see the changes that would be implemented, add ***‘--diff’. ‘*** diff flag alone implements the changes after pointing them out to you.

#### Idempotency: 

> This is an IaC property that ensures a defined infrastructure
> deployment sets the target environment to the desired state, every
> time it is run, regardless of its starting state. The IaC provider
> will decide what needs to be stood-up, torn down or reconfigure to
> match your described target state.

## Ansible Playbook
The ansible playbook is a more readable, versionable way of executing tasks using ansible. In comparison with ad-hoc commands, playbooks are used in complex scenarios, and they offer increased flexibility and capability. Playbooks use YAML format, so there is not much syntax needed, but its indentation rules are strict.  Ansible playbooks tend to be more of a configuration language than a programming language.

> Like its name, a playbook is a collection of plays. A play is a set of
> orchestration instructions.

    ---
      #ansible -m copy -a “src=./file1.txt dest=~/file1.txt” localhost
    - name: Play name
    hosts: localhost
      tasks:
      - name: Copy a file
        copy:
          src: ./file1.txt
          dest: ~/file1.txt
         
          

 - An ansible playbook starts with the 3 dashes.
 - "#" indicates a comment line.
 - The - name indicates a non-executed name that serves a descriptive
   purpose.
 - Hosts specifies the target node device, or groups.
 - A task is made up of an action and its args.
 - Under tasks you can specify your modules and its parameter.

> If the action you desire requires root/sudo, use the ‘***Become***’ keyword
> for privilege escalation.

## Ansible Inventory
Ansible uses the Inventory to identify its managed hosts. The default host file is at:

    /etc/ansible/hosts 

Here you define your nodes, node alias, node groups and variables. Create a group with the ip addresses of the VMs you created. 

    [master]
    host1 192.168.100.2 ansible_user=agent ansible_password=password@101
    [agents]
    Node1 192.168.100.3 ansible_user=agent ansible_password=password@101
    Node1 192.168.100.3 ansible_user=agent ansible_password=password@101

The ‘***ansible-inventory***’ command is used for working with the managed nodes. 
To see a full list of all our nodes type:

    Ansible-inventory --list

For a more graphical layout use:

    Ansible-inventory --graph

 - **@localhost** refers to the current/control node
 - **@all** refers to all the nodes
 - **@<group_name>** targets all nodes under a group.

To simplify our host file, define all variables in the [all:vars] group:

    [all:vars]
    Ansible_user=agent
    Ansible_password=password@101
    
    [master]
    host1 192.168.100.2 
    
    [agents]
    Node1 192.168.100.3 
    Node1 192.168.100.3 

Let us try to test our hosts with the ***ping*** command:

    Ansible -m ping all

Gives us error. We need to modify some ansible configuration. 
## Ansible CFG
The ansible configuration file is exactly what you expect it to be. Its located at:

    /etc/ansible/ansible.cfg

 We’ll need to open it and modify a setting. Open the file and uncomment:  `host_key_checking = false`
Or enter it. 
Now you can run your ping command:

    Ansible -m ping all

## Writing a Playbook
**Create a file:**

    Touch playbook.yml

Open it and add the following into it:

    ---
    - name: play one - install vim from custom inventory
      hosts: agents
      become: true
      tasks:
      - name: apt 
        apt:
          name: vim
          state: latest
      
      - name: zsh install
        apt:
          name: zsh
          state: latest
    
      - name: vagrant install
        apt:
          name: vagrant
          state: latest
    
      - name: nodejs install
        apt:
          name: nodejs
          state: latest
    
    - name: play two server config
      become: true
      hosts: master
      tasks:
        - name: ensure Nginx is at latest
          apt:
            name: nginx
            state: latest
        - name: start server
          service:
            name: nginx
            state: started

Save it.
## Executing a Playbook
To execute the play we just wrote, we use the ‘ansible-playbook’ command. Enter:

    Ansible-playbook playbook.yml -v

The **-v is for verbosity.** The more the v’s the more details that would be output.
We can also execute a playbook from a custom inventory file.
Create a custom inventory file. 

    Touch inventory

Add nodes to it.

Ping test it with the following:

    Ansible -I inventory -m ping all

Run a playbook off it with:

    Ansible-playbook -I inventory playbook.yml

---
---
# Shut-down our VMs
Now, as a final demo, lets shutdown our VMs to avoid extra charges. Since we know ansible can do all sorts of things, lets use it for this demo. 
Can you write the yaml script for this. Try it out first. Its a simple one.

    ---
    - name: shut down all my agent vms
      hosts: all
      become: true
      tasks:
        - name: run shutdown command
          command: shutdown

Save and execute this:

    Ansible-playbook shutdownVMs.yml -vv

---
***Thanks for your time!***




