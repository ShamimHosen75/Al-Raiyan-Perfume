import { ImageUpload } from '@/components/admin/ImageUpload';
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { Button } from '@/components/ui/button';
import {
    Dialog,
    DialogContent,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { useAddCustomReview, useAllReviews, useApproveReview, useDeleteReview } from '@/hooks/useProductReviews';
import { cn } from '@/lib/utils';
import { Check, MessageSquare, Plus, Star, Trash2, X } from 'lucide-react';
import { useState } from 'react';

export default function AdminReviews() {
  const { data: reviews = [], isLoading } = useAllReviews(false);
  const approveReview = useApproveReview();
  const deleteReview = useDeleteReview();
  const addCustomReview = useAddCustomReview();
  
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [filter, setFilter] = useState<'all' | 'pending' | 'approved'>('all');
  
  // Custom Review Modal State
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [newReview, setNewReview] = useState({
    name: '',
    rating: 5,
    text: '',
    image_url: '',
  });

  const filteredReviews = reviews.filter((review) => {
    if (filter === 'pending') return !review.is_approved;
    if (filter === 'approved') return review.is_approved;
    return true;
  });

  const pendingCount = reviews.filter((r) => !r.is_approved).length;

  const handleDelete = async () => {
    if (!deleteId) return;
    await deleteReview.mutateAsync(deleteId);
    setDeleteId(null);
  };

  const handleAddReview = async () => {
    if (!newReview.name.trim() || !newReview.text.trim()) return;
    
    await addCustomReview.mutateAsync({
      name: newReview.name,
      rating: newReview.rating,
      text: newReview.text,
      image_url: newReview.image_url || undefined,
    });
    
    setIsAddModalOpen(false);
    setNewReview({ name: '', rating: 5, text: '', image_url: '' });
  };

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
    });
  };

  return (
    <div>
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
        <div>
          <h1 className="text-2xl md:text-3xl font-bold">Reviews</h1>
          {pendingCount > 0 && (
            <p className="text-sm text-muted-foreground">
              {pendingCount} review{pendingCount !== 1 ? 's' : ''} pending approval
            </p>
          )}
        </div>
        <Button onClick={() => setIsAddModalOpen(true)} className="btn-accent">
          <Plus className="h-4 w-4 mr-2" />
          Add Custom Review
        </Button>
      </div>

      {/* Filter Tabs */}
      <div className="flex gap-2 mb-6">
        {(['all', 'pending', 'approved'] as const).map((f) => (
          <Button
            key={f}
            variant={filter === f ? 'default' : 'outline'}
            size="sm"
            onClick={() => setFilter(f)}
            className={filter === f ? 'btn-accent' : ''}
          >
            {f.charAt(0).toUpperCase() + f.slice(1)}
            {f === 'pending' && pendingCount > 0 && (
              <span className="ml-2 bg-destructive text-destructive-foreground text-xs px-1.5 py-0.5 rounded-full">
                {pendingCount}
              </span>
            )}
          </Button>
        ))}
      </div>

      {/* Reviews List */}
      <div className="bg-card rounded-xl border border-border overflow-hidden">
        {isLoading ? (
          <div className="p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-accent mx-auto" />
          </div>
        ) : filteredReviews.length === 0 ? (
          <div className="p-8 text-center text-muted-foreground">
            <MessageSquare className="h-12 w-12 mx-auto mb-3 opacity-50" />
            <p>No reviews found</p>
          </div>
        ) : (
          <div className="divide-y divide-border">
            {filteredReviews.map((review) => (
              <div key={review.id} className="p-4 sm:p-6">
                <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <span className="font-medium">{review.name}</span>
                      <div className="flex">
                        {[1, 2, 3, 4, 5].map((star) => (
                          <Star
                            key={star}
                            className={cn(
                              "h-4 w-4",
                              star <= review.rating
                                ? "fill-yellow-400 text-yellow-400"
                                : "text-muted"
                            )}
                          />
                        ))}
                      </div>
                      <span
                        className={cn(
                          "text-xs px-2 py-0.5 rounded-full",
                          review.is_approved
                            ? "bg-green-100 text-green-700"
                            : "bg-yellow-100 text-yellow-700"
                        )}
                      >
                        {review.is_approved ? 'Approved' : 'Pending'}
                      </span>
                    </div>
                    <p className="text-muted-foreground mb-2">{review.text}</p>
                    <p className="text-xs text-muted-foreground">{formatDate(review.created_at)}</p>
                  </div>

                  <div className="flex gap-2">
                    {!review.is_approved ? (
                      <Button
                        size="sm"
                        variant="outline"
                        className="text-green-600 hover:bg-green-50"
                        onClick={() => approveReview.mutate({ id: review.id, approved: true })}
                        disabled={approveReview.isPending}
                      >
                        <Check className="h-4 w-4 mr-1" />
                        Approve
                      </Button>
                    ) : (
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => approveReview.mutate({ id: review.id, approved: false })}
                        disabled={approveReview.isPending}
                      >
                        <X className="h-4 w-4 mr-1" />
                        Unapprove
                      </Button>
                    )}
                    <Button
                      size="sm"
                      variant="outline"
                      className="text-destructive hover:bg-destructive/10"
                      onClick={() => setDeleteId(review.id)}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Delete Confirmation */}
      <AlertDialog open={!!deleteId} onOpenChange={() => setDeleteId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Review</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to delete this review? This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleDelete}
              className="bg-destructive text-destructive-foreground"
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Add Custom Review Modal */}
      <Dialog open={isAddModalOpen} onOpenChange={setIsAddModalOpen}>
        <DialogContent className="sm:max-w-[500px]">
          <DialogHeader>
            <DialogTitle>Add Custom Review</DialogTitle>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="name">Customer Name *</Label>
              <Input
                id="name"
                placeholder="e.g. Fatima Rahman"
                value={newReview.name}
                onChange={(e) => setNewReview({ ...newReview, name: e.target.value })}
              />
            </div>
            
            <div className="space-y-2">
              <Label>Rating *</Label>
              <div className="flex items-center gap-2">
                <div className="flex bg-slate-50 p-2 rounded-md">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <Star
                      key={star}
                      className={cn(
                        "h-8 w-8 cursor-pointer transition-colors",
                        star <= newReview.rating
                          ? "fill-yellow-400 text-yellow-400"
                          : "text-slate-200 fill-slate-200"
                      )}
                      onClick={() => setNewReview({ ...newReview, rating: star })}
                    />
                  ))}
                </div>
                <span className="text-muted-foreground ml-2">{newReview.rating} / 5</span>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="text">Review Text *</Label>
              <Textarea
                id="text"
                placeholder="Write the customer's review here..."
                value={newReview.text}
                onChange={(e) => setNewReview({ ...newReview, text: e.target.value })}
                className="min-h-[120px] resize-none"
              />
            </div>

            <div className="space-y-2">
              <Label>Customer Photo (optional)</Label>
              <ImageUpload
                value={newReview.image_url}
                onChange={(url) => setNewReview({ ...newReview, image_url: url })}
                folder="reviews"
                className="w-full"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsAddModalOpen(false)}>
              Cancel
            </Button>
            <Button 
              className="btn-accent"
              onClick={handleAddReview}
              disabled={!newReview.name.trim() || !newReview.text.trim() || addCustomReview.isPending}
            >
              {addCustomReview.isPending ? 'Adding...' : 'Add Review'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
