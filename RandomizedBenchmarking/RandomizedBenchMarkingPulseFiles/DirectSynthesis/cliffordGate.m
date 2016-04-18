classdef cliffordGate < handle
    %clifford gate which is a composite of some primitive gates.
    
    properties
        name; % string generated using index of generated clifford
        unitary; % a 2x2 matrix corresponding to the action of the clifford
        primDecomp; % object array containing primitive gate objects.  These are actually handles to the RBExperiments.primitives objects
    end
    
    methods
        function obj=cliffordGate(index,unitary, primDecomp)
            obj.name = ['C' num2str(index)];
            obj.unitary=unitary;
            obj.primDecomp=primDecomp;
        end
        
        function draw(obj) % visualize the gate
            % print some text
            fprintf(['Clifford name: ' obj.name '\n'])
            fprintf(['Decomposition: ' [obj.primDecomp.name] '\n'])
%             fprintf(['rotation: ' num2str(obj.rotation) '\n'])
%             fprintf(['unitary rotation matrix:\n'])
%             disp(obj.unitary)
        end
    end
end
            
       
        