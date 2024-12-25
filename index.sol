// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Companies{   

       uint256 public present_trip_counter=0;
       uint256 public total_weight=0;
      struct today_total{
           string date;
           uint256 weight;
      }
      struct Owner{
          address payable owner;
          string ownerid;
      }

      struct user {
              address payable owner;
              string userid;
      }
      struct collector{
          address owner;
          string collectorid;
          uint256 present_trip_no;
      }
      struct bag{
         uint256 weight;
         string  collectorid;
         string userid;
         uint256 timestamp;
         uint256 tripno;
      }

      struct trip{
        uint256 tripno;
        uint256 weight;
        string collectorid;
        uint256 no_of_users;
        string[] users;
        uint256[] weight_of_user;
        bool isvalid;
      }
     
      mapping(string=>today_total) public Day_wise_check;
      mapping(string=>Owner) public owners;
      mapping(string=>user) public users;
      mapping(string=>collector)public collectors;
      mapping(uint256=>trip) public trips;
      mapping(uint256=>collector) public collectors_trip_track;
      mapping(string=>mapping(uint256=>bag)) public Detailed_data; 

       
            constructor(){
                 owners["1234"]=Owner({
                owner:payable(msg.sender),
                ownerid:"1234"
                 });
            }

      event bag_added(
           collector indexed collector,
           bag indexed   bag,
           trip indexed trip
      );

      event reached(
           collector indexed collector,
           trip indexed trip
      );

      modifier onlyCollector(string memory collectorid){
             require(msg.sender==collectors[collectorid].owner,"only collector");
             _;
      }
      modifier onlyOwner(string memory ownerid){
          require(msg.sender==owners[ownerid].owner,"this is owner only function");
          _;
      }


      function Addbag(uint256 weight,
         string memory collectorid,
         string memory userid,
         string memory date)   public onlyCollector(collectorid){

                  require(weight>0,"weight not sufficient");
                  total_weight+=weight;

                  Detailed_data[date][block.timestamp]=bag({
                        weight:weight,
        collectorid:collectorid,
         userid:userid,
         timestamp:block.timestamp,
         tripno:collectors[collectorid].present_trip_no
                  });

           uint256 current_trip_no=collectors[collectorid].present_trip_no;

           trips[current_trip_no].weight+=weight;
           trips[current_trip_no].no_of_users+=1;
           trips[current_trip_no].users.push(userid);
           trips[current_trip_no].weight_of_user.push(weight);


         emit bag_added(collectors[collectorid],Detailed_data[date][block.timestamp], trips[current_trip_no]);

         }   

         function assigntrip(string memory collectorid,string memory ownerid) public onlyOwner(ownerid){

            collector storage cl=collectors[collectorid];

            require(cl.present_trip_no==0,"collector already asiined");
              
                 present_trip_counter+=1 ;
                 trips[present_trip_counter]=trip({
                   tripno:present_trip_counter,
        weight:0,
        collectorid:collectorid,
        no_of_users:0,
        users:new string[](0),
        weight_of_user:new uint[](0),
        isvalid:true


   
        
                 });

                 collectors[collectorid].present_trip_no=present_trip_counter;

           
                
         }

         function adduser(string memory userid) public {
                 user memory u = users[userid]; 

   
                    if(u.owner== address(0)){
                           users[userid]=user({
                                    owner:payable(msg.sender),
                                    userid:userid   
                           });
                    }
         }

        function addCollector(string memory collectorid,string memory ownerid) public onlyOwner(ownerid){
               collector memory u = collectors[collectorid]; 

   
                    if(u.owner == address(0)){
                           collectors[collectorid]=collector({
                                    owner:payable(msg.sender),
                                    collectorid:collectorid,
                                    present_trip_no:0   
                           });
                    }
        }
       
        function finishTrip(string memory collectorid,string memory ownerid,uint256 per) public payable onlyOwner(ownerid){
                 collector memory u = collectors[collectorid]; 
                 trip memory tp=trips[u.present_trip_no];

                 require(tp.isvalid,"trip finished previously");

                 uint256  totalamount=msg.value;


                 string [] memory users_waiting=tp.users;
                 uint256[] memory weights=tp.weight_of_user;

                 uint256 c=0;
                 uint256 n=users_waiting.length;

                 for(uint256 i=0;i<n;i++){
                      if(totalamount<weights[i]*per){
                         c=1;
                         break;
                      }
                         totalamount-=weights[i]*per;


                 }
                 require(c==0,"funds not sufficient");

                 for(uint256 i=0;i<n;i++){
                    user memory us=users[users_waiting[i]];
                     address payable use = payable(us.owner);
            use.transfer(weights[i]*per);
                 }
              trips[u.present_trip_no].isvalid=false;
              u.present_trip_no=0;
          
          emit reached(u, tp);



        }


        function getdata(string memory  date,uint256 time) public view returns(
          uint256 weight,
         string memory collectorid,
         string memory userid,
         uint256 timestamp,
         uint256 tripno
        ){
          bag memory bg=  Detailed_data[date][time];

          return(bg.weight,bg.collectorid,bg.userid,bg.timestamp,bg.tripno);
                 
            
        }
     
       function endofday(string memory date) public{
            
               require(bytes(date).length==6,"date format ddmmyy");

               Day_wise_check[date]=today_total({
                  date:date,
                  weight:total_weight
               });
               total_weight=0;
               present_trip_counter=0;           
       }








                


       }





